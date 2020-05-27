# frozen_string_literal: true

require_relative 'db_pg'
require_relative 'telegram_bot'

class Wallet

	def buy_coin(coin, quantity, chat_id)
    last_wallet_id

    user_have_coin= DBPG::CON.exec "SELECT * FROM Wallets WHERE User_Id = #{chat_id} AND Coin = '#{coin}'"

    if user_have_coin.values.length > 0
       DBPG::CON.exec "UPDATE Wallets SET Quantity = #{user_have_coin.values[0][2].to_f + quantity} WHERE User_Id = #{chat_id}"
    else
      DBPG::CON.exec "INSERT INTO Wallets VALUES(#{@last_id + 1}, '#{coin}', #{quantity}, #{chat_id} )"
    end  
	end

  def show_wallet(message)
      kb = [
        Telegram::Bot::Types::KeyboardButton.new(text: "Back to home", one_time_keyboard: true),
        Telegram::Bot::Types::KeyboardButton.new(text: "Sell coin", one_time_keyboard: true),
      ]
      markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: kb)
      TelegramBot.new.bot.api.send_message(chat_id: message.chat.id, text: 'Your wallet', reply_markup: markup)

      user_wallet = DBPG::CON.exec "SELECT * FROM Wallets WHERE User_Id = #{message.chat.id}"
      amount_usd = 0
      user_wallet.values.each do |value|
        parameters = { 'X-CMC_PRO_API_KEY' => CryptoBotIndex::API_KEY, 'start' => '1', 'limit' => '1', 'convert' => "USD,#{value[1]}" }
        @coin_price = CryptoBotIndex.coinmarket_api(message, parameters, value[1])
        amount_usd += @coin_price * value[2].to_f
        TelegramBot.new.send_message(message.chat.id, "#{value[1]} quantity - #{value[2]}, total(#{value[1]}) - #{@coin_price * value[2].to_f}")
      end
      TelegramBot.new.send_message(message.chat.id, "Amount = #{amount_usd}")
  end

	private

  def last_wallet_id
    wallet = DBPG::CON.exec 'SELECT * FROM Wallets'
    @last_id = 0
    wallet.each do |row| 
      @last_id = row['id'].to_i
    end
  end
end
