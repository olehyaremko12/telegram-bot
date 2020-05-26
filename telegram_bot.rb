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

class TelegramBot
  TOKEN = '1246743304:AAFY4X3KH0BxPPbL0UtIPGZf3ExvpW8FGH8'
  ARRCOIN = %w[BTC ETH XRP BCH].freeze

  def coin_message
    bot.listen do |message|
      arr_name_btn = ['Start', 'Wallet', 'Transaction', 'Terms of Use']
      kb = [
        Telegram::Bot::Types::KeyboardButton.new(text: arr_name_btn[0], one_time_keyboard: true),
        Telegram::Bot::Types::KeyboardButton.new(text: arr_name_btn[1], one_time_keyboard: true),
        Telegram::Bot::Types::KeyboardButton.new(text: arr_name_btn[2], one_time_keyboard: true),
        Telegram::Bot::Types::KeyboardButton.new(text: arr_name_btn[3], one_time_keyboard: true)

      ]
      markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: kb)

      if arr_name_btn.include?(message.text) == false
        bot.api.send_message(chat_id: message.chat.id, text: 'Choose the button', reply_markup: markup)
      end

      if message.text == 'Start'
        start
        User.new.add_user(message.chat.first_name, message.chat.id)
      end
      terms if message.text == 'Terms of Use'
      Wallet.new if message.text == 'Wallet'
      Transaction.new if message.text == 'Transaction'
    end
  end

  def terms
    bot.listen do |message|
      kb = [
        Telegram::Bot::Types::KeyboardButton.new(text: 'Back to start', one_time_keyboard: true)
      ]
      markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: kb)

      if message.text == 'Terms of Use'
        bot.api.send_message(chat_id: message.chat.id, text: 'This bot is simulation of trading platform, all that you do in this bot is for fun and training your skills at trading. For start we give you 1000 poin, 1 point = 1 $. Have fun)))', reply_markup: markup)
      end

      coin_message if message.text == 'Back to start'
    end
  end

  def start
    bot.listen do |message|
      kb = [
        Telegram::Bot::Types::KeyboardButton.new(text: 'BTC', one_time_keyboard: true),
        Telegram::Bot::Types::KeyboardButton.new(text: 'ETH', one_time_keyboard: true),
        Telegram::Bot::Types::KeyboardButton.new(text: 'XRP', one_time_keyboard: true),
        Telegram::Bot::Types::KeyboardButton.new(text: 'BCH', one_time_keyboard: true),
        Telegram::Bot::Types::KeyboardButton.new(text: 'Home', one_time_keyboard: true)
      ]
      markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: kb)

      if message.text == 'Start' || message.text == 'Back to chose coin'
        bot.api.send_message(chat_id: message.chat.id, text: 'Please chose coin', reply_markup: markup)
        end

      coin(message.text) if ARRCOIN.include?(message.text)

      coin_message if message.text == 'Home'
    end
  end

  def coin(currency)
    bot.listen do |message|
      name_coin = currency
      kb = [
        Telegram::Bot::Types::KeyboardButton.new(text: 'Price', one_time_keyboard: true),
        Telegram::Bot::Types::KeyboardButton.new(text: 'Back to chose coin', one_time_keyboard: true)
      ]
      markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: kb)

      if ARRCOIN.include?(message.text) || message.text == 'Back to previous step'
        bot.api.send_message(chat_id: message.chat.id, text: 'Please chose next step', reply_markup: markup)
         end

      price(message, name_coin) if message.text == 'Price'

      start if message.text == 'Back to chose coin'
    end
  end

  def price(message, name_coin)
    bot.listen do |message|
      if message.text == 'Price'
        parameters = { 'X-CMC_PRO_API_KEY' => CryptoBotIndex::API_KEY, 'start' => '1', 'limit' => '1', 'convert' => "USD,#{name_coin}" }
        @coin_price = CryptoBotIndex.coinmarket_api(message, parameters, name_coin)
      end
      kb = [
        Telegram::Bot::Types::KeyboardButton.new(text: 'Buy', one_time_keyboard: true),
        Telegram::Bot::Types::KeyboardButton.new(text: 'Back to previous step', one_time_keyboard: true)
      ]
      markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: kb)

      if message.text == 'Price'
        bot.api.send_message(chat_id: message.chat.id, text: 'Please chose next step', reply_markup: markup)
      end

      buy(message, name_coin, @coin_price) if message.text == 'Buy'

      coin(name_coin) if message.text == 'Back to previous step'
    end
  end

  def buy(_message, name_coin, coin_price)
    bot.listen do |message|
      coin = name_coin
      bot.api.send_message(chat_id: message.chat.id, text: 'Please write quantity coin that you wanna buy')
      if message.text.to_f > 0
        Transaction.new.add_transaction("buy", coin, message.text.to_f, coin_price, message.chat.id)
        Wallet.new.buy_coin(coin, message.text.to_f, message.chat.id)
      end
    end
  end

  def send_message(chat_id, message)
    bot.api.sendMessage(chat_id: chat_id, text: message)
  end

  private

  def bot
    Telegram::Bot::Client.run(TOKEN) { |bot| return bot }
  end
end
