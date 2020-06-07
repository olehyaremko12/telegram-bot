# frozen_string_literal: true

require_relative 'db_pg'
require_relative 'crypto_bot_index'
require_relative 'transaction'
require_relative 'user'
require_relative 'wallet'

require 'telegram/bot'
require 'rest-client'
require 'json'
require 'pry'

# main bot navigation
class TelegramBot
  TOKEN = '1246743304:AAFY4X3KH0BxPPbL0UtIPGZf3ExvpW8FGH8'
  ARRCOIN = %w[BTC ETH XRP BCH].freeze
  BTN = Telegram::Bot::Types::KeyboardButton

  def coin_message
    bot.listen do |message|
      arr_name_btn = ['Start', 'Wallet', 'Transaction', 'Terms of Use']
      iterate_btn(arr_name_btn)

      if arr_name_btn.include?(message.text) == false
        bot.api.send_message(chat_id: message.chat.id, text: 'Choose the button', reply_markup: @markup)
      end

      if message.text == 'Start'
        User.new.add_user(message.chat.first_name, message.chat.id)
        start
      end
      terms if message.text == 'Terms of Use'
      Wallet.new.show_wallet(message) if message.text == 'Wallet'
      Transaction.new.show_transaction(message) if message.text == 'Transaction'
    end
  end

  def terms
    bot.listen do |message|
      arr_name_btn = ['Back to start']
      iterate_btn(arr_name_btn)

      if message.text == 'Terms of Use'
        terms = File.open('terms.txt')
        bot.api.send_message(chat_id: message.chat.id, text: terms.read, reply_markup: @markup)
      end

      coin_message if message.text == 'Back to start'
    end
  end

  def start
    bot.listen do |message|
      arr_name_btn = %w[BTC ETH XRP BCH Home]
      iterate_btn(arr_name_btn)

      if message.text == 'Start' || message.text == 'Back to chose coin'
        bot.api.send_message(chat_id: message.chat.id, text: 'Please chose coin', reply_markup: @markup)
      end

      coin(message.text) if ARRCOIN.include?(message.text)

      coin_message if message.text == 'Home'
    end
  end

  def coin(currency)
    bot.listen do |message|
      arr_name_btn = ['Price', 'Back to chose coin']
      iterate_btn(arr_name_btn)
      name_coin = currency

      if ARRCOIN.include?(message.text) || message.text == 'Back to previous step'
        bot.api.send_message(chat_id: message.chat.id, text: 'Please chose next step', reply_markup: @markup)
      end

      price(message, name_coin) if message.text == 'Price'

      start if message.text == 'Back to chose coin'
    end
  end

  def price(_message, name_coin)
    bot.listen do |message|
      @coin_price = CryptoBotIndex.new.parameter_api(message, name_coin) if message.text == 'Price'
      arr_name_btn = ['Buy', 'Back to previous step']
      iterate_btn(arr_name_btn)

      if message.text == 'Price'
        bot.api.send_message(chat_id: message.chat.id, text: 'Please chose next step', reply_markup: @markup)
      end

      buy(message, name_coin, @coin_price) if message.text == 'Buy'

      coin(name_coin) if message.text == 'Back to previous step'
    end
  end

  def buy(_message, name_coin, coin_price)
    bot.listen do |message|
      coin = name_coin

      if message.text == 'Buy'
        bot.api.send_message(chat_id: message.chat.id, text: 'Please write quantity coin that you wanna buy')
      end

      Wallet.new.buy_coin(coin, message, message.chat.id, coin_price) if message.text.to_f > 0

      price(message, name_coin) if message.text == 'Back to previous step'
    end
  end

  def send_message(chat_id, message)
    bot.api.sendMessage(chat_id: chat_id, text: message)
  end

  def bot
    Telegram::Bot::Client.run(TOKEN) { |bot| return bot }
  end

  def iterate_btn(arr_btn)
    @kb = []
    arr_btn.each do |val|
      @kb.push(TelegramBot::BTN.new(text: val.to_s, one_time_keyboard: true))
    end
    @markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: @kb)
  end
end
