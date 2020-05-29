# frozen_string_literal: true

require_relative 'db_pg'

class Transaction

	def add_transaction(kind, coin, quantity, price, chat_id)
    last_transaction_id

    DBPG::CON.exec "INSERT INTO Transactions VALUES( #{@last_id + 1},'#{kind}', '#{coin}', #{quantity}, #{price}, #{chat_id})"
  end

  def show_transaction(message)
    TelegramBot.new.bot.listen do |message|
      kb = [
        Telegram::Bot::Types::KeyboardButton.new(text: "Buy transactions", one_time_keyboard: true),
        Telegram::Bot::Types::KeyboardButton.new(text: "Sell transactions", one_time_keyboard: true),
        Telegram::Bot::Types::KeyboardButton.new(text: "Back to home", one_time_keyboard: true)
      ]
      markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: kb)
      if message.text == 'Transaction'
        TelegramBot.new.bot.api.send_message(chat_id: message.chat.id, text: 'Choose what kind of transaction you wanna see', reply_markup: markup)
      end
      buy_transaction if message.text == "Buy transactions"
      sell_transaction if message.text == "Sell transactions"
      TelegramBot.new.coin_message if message.text == "Back to home"
    end
  end

  def buy_transaction
    TelegramBot.new.bot.listen do |message|
      if message.text == "Buy transactions"
        user_transaction = DBPG::CON.exec "SELECT * FROM Transactions WHERE User_Id = #{message.chat.id} AND Kinds = 'buy'"
        user_transaction.values.each do |value|
          TelegramBot.new.send_message(message.chat.id, "coin - #{value[2]}, quantity - #{value[3]}, price - #{value[4]}")
        end
      end
      sell_transaction if message.text == "Sell transactions"
      TelegramBot.new.coin_message if message.text == "Back to home"
    end
  end

  def sell_transaction
    TelegramBot.new.bot.listen do |message|
      if message.text == "Sell transactions"
        user_transaction = DBPG::CON.exec "SELECT * FROM Transactions WHERE User_Id = #{message.chat.id} AND Kinds = 'sell'"
        user_transaction.values.each do |value|
          TelegramBot.new.send_message(message.chat.id, "coin - #{value[2]}, quantity - #{value[3]}, price - #{value[4]}")
        end
      end
      buy_transaction if message.text == "Buy transactions"
      TelegramBot.new.coin_message if message.text == "Back to home"
    end

  end
    
  private

  def last_transaction_id
    transactions = DBPG::CON.exec 'SELECT * FROM Transactions'
    @last_id = 0
    transactions.each do |row| 
      @last_id = row['id'].to_i
    end
  end
end
