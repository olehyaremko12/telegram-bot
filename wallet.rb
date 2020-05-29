# frozen_string_literal: true

require_relative 'db_pg'
require_relative 'telegram_bot'

class Wallet

	def buy_coin(coin, message, chat_id, coin_price)
    quantity = message.text.to_f
    last_wallet_id
    user_points(chat_id)

    user_have_coin= DBPG::CON.exec "SELECT * FROM Wallets WHERE User_Id = #{chat_id} AND Coin = '#{coin}'"

    if quantity * coin_price <= @points_quantity
      @points_quantity -= quantity * coin_price
      if user_have_coin.values.length > 0
        DBPG::CON.exec "UPDATE Wallets SET Quantity = #{user_have_coin.values[0][2].to_f + quantity} WHERE User_Id = #{chat_id} AND Coin = '#{coin}'"
      else
        DBPG::CON.exec "INSERT INTO Wallets VALUES(#{@last_id + 1}, '#{coin}', #{quantity}, #{chat_id} )"
      end
      DBPG::CON.exec "UPDATE Wallets SET Quantity = #{@points_quantity} WHERE User_Id = #{chat_id} AND Coin = 'Point'"
      Transaction.new.add_transaction("buy", coin, message.text.to_f, coin_price, message.chat.id)
      TelegramBot.new.bot.api.send_message(chat_id: message.chat.id, text: "You just buy #{message.text} #{coin}")
    else
      TelegramBot.new.bot.api.send_message(chat_id: message.chat.id, text: 'You don`t have enough points')
    end
	end

  def show_wallet(message)
    TelegramBot.new.bot.listen do |message|
      kb = [
        Telegram::Bot::Types::KeyboardButton.new(text: "Sell coin", one_time_keyboard: true),
        Telegram::Bot::Types::KeyboardButton.new(text: "Back to home", one_time_keyboard: true),
      ]
      markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: kb)
      
      TelegramBot.new.coin_message if message.text == 'Back to home'
      sell_coin(message) if message.text == 'Sell coin'

      if message.text == 'Wallet' || message.text == "Back to wallet"
        TelegramBot.new.bot.api.send_message(chat_id: message.chat.id, text: 'Your wallet', reply_markup: markup)
        user_wallet = DBPG::CON.exec "SELECT * FROM Wallets WHERE User_Id = #{message.chat.id}"
        amount_usd = 0
        user_wallet.values.each do |value|
          parameters = { 'X-CMC_PRO_API_KEY' => CryptoBotIndex::API_KEY, 'start' => '1', 'limit' => '1', 'convert' => "USD,#{value[1]}" }
          @coin_price = CryptoBotIndex.coinmarket_api(message, parameters, value[1])
          if value[1] != "Point"
            amount_usd += @coin_price * value[2].to_f
            TelegramBot.new.send_message(message.chat.id, "#{value[1]} quantity - #{value[2]}, total(#{value[1]}) - #{@coin_price * value[2].to_f}")
          else
            amount_usd += value[2].to_f
            TelegramBot.new.send_message(message.chat.id, "#{value[1]} quantity - #{value[2]}")
          end
        end
        TelegramBot.new.send_message(message.chat.id, "Amount = #{amount_usd}")
      end
    end
  end

  def sell_coin(message)
    TelegramBot.new.bot.listen do |message|
      kb = [
        Telegram::Bot::Types::KeyboardButton.new(text: "Back to wallet", one_time_keyboard: true),
      ]
      user_wallet = DBPG::CON.exec "SELECT * FROM Wallets WHERE User_Id = #{message.chat.id}"
      user_wallet.values.each do |value|
        if value[1] != "Point"
          kb.push(Telegram::Bot::Types::KeyboardButton.new(text: "#{value[1]}", one_time_keyboard: true))
        end
      end      
      markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: kb)

      if message.text == 'Sell coin'
        TelegramBot.new.bot.api.send_message(chat_id: message.chat.id, text: 'Choose what coin you wanna sell', reply_markup: markup)
      end

      sell_current_coin(message) if TelegramBot::ARRCOIN.include?(message.text)
      show_wallet(message) if message.text == "Back to wallet"
    end
  end

  def sell_current_coin(message)
    TelegramBot.new.bot.listen do |message|

      if TelegramBot::ARRCOIN.include?(message.text)
        TelegramBot.new.bot.api.send_message(chat_id: message.chat.id, text: "Write quantity #{message.text} that you wanna sell")
      end
      current_quantity_coin(message)
      sell_coin(message) if message.text == "Back to wallet"

      if message.text.to_f <= @current_quantity && TelegramBot::ARRCOIN.include?(message.text) == false 
        DBPG::CON.exec "UPDATE Wallets SET Quantity = #{@current_quantity - message.text.to_f} WHERE User_Id = #{message.chat.id} AND Coin = '#{@coin}'"
        parameters = { 'X-CMC_PRO_API_KEY' => CryptoBotIndex::API_KEY, 'start' => '1', 'limit' => '1', 'convert' => "USD,#{@coin}" }
        @coin_price = CryptoBotIndex.coinmarket_api(message, parameters, @coin)
        Transaction.new.add_transaction("sell", @coin, message.text.to_f, @coin_price, message.chat.id)
        TelegramBot.new.bot.api.send_message(chat_id: message.chat.id, text: "You just sold #{message.text} #{@coin}")
        user_points(message.chat.id)
        @sell_points_quantity = (message.text.to_f * @coin_price) + @points_quantity
        DBPG::CON.exec "UPDATE Wallets SET Quantity = #{@sell_points_quantity} WHERE User_Id = #{message.chat.id} AND Coin = 'Point'"
      end 
    end
  end

	private

  def last_wallet_id
    wallet = DBPG::CON.exec 'SELECT * FROM Wallets'
    @last_id = 0
    wallet.each do |row| 
      @last_id = row['id'].to_i
    end
  end

  def current_quantity_coin(message)
    user_wallet = DBPG::CON.exec "SELECT * FROM Wallets WHERE User_Id = #{message.chat.id} AND Coin = '#{message.text}'"
    user_wallet.values.each do |value|
      @current_quantity = value[2].to_f
      @coin = value[1]
    end
  end

  def user_points(chat_id)
    user_points = DBPG::CON.exec "SELECT * FROM Wallets WHERE User_Id = #{chat_id} AND Coin = 'Point'"
    @points_quantity = user_points.values[0][2].to_f
  end
end
