# frozen_string_literal: true

require_relative 'db_pg'
require_relative 'crypto_bot_index'

require 'telegram/bot'
require 'rest-client'
require 'json'
require 'pry'

class TelegramBot
  TOKEN = '1246743304:AAFY4X3KH0BxPPbL0UtIPGZf3ExvpW8FGH8'
  ARRCOIN = ['BTC', 'ETH', 'XRP', 'BCH'].freeze

  def coin_message
    bot.listen do |message|
	  	kb = [
	    	Telegram::Bot::Types::KeyboardButton.new(text: 'Start', one_time_keyboard: true)
	    ]
	  	markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: kb)

      if message.text !=  'Start'
	  	  bot.api.send_message(chat_id: message.chat.id, text: 'Press the button start', reply_markup: markup)
	  	end

	  	start() if message.text == 'Start' 
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

	  	coin_message() if message.text == 'Home'
    end
  end

  def coin(currency)
    bot.listen do |message|
			name_coin = currency
	    kb = [
		   	Telegram::Bot::Types::KeyboardButton.new(text: 'Price', one_time_keyboard: true),
		   	Telegram::Bot::Types::KeyboardButton.new(text: 'Back to chose coin', one_time_keyboard: true),
		  ]
		  markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: kb)

      if ARRCOIN.include?(message.text) || message.text == 'Back to previous step'
		    bot.api.send_message(chat_id: message.chat.id, text: 'Please chose next step', reply_markup: markup)
	    end 

	    price(message, name_coin) if message.text == 'Price'

	    start() if message.text == 'Back to chose coin'
    end
  end

  def price(message, name_coin)
    bot.listen do |message|
      if message.text == 'Price'
  		  parameters = { 'X-CMC_PRO_API_KEY' => CryptoBotIndex::API_KEY, 'start'=>'1', 'limit'=>'1', 'convert'=>"USD,#{name_coin}"}
  		  @coin_price = CryptoBotIndex.coinmarket_api(message, parameters, name_coin)
      end  
	   	kb = [
		   	Telegram::Bot::Types::KeyboardButton.new(text: 'Buy', one_time_keyboard: true),
		   	Telegram::Bot::Types::KeyboardButton.new(text: 'Back to previous step', one_time_keyboard: true),
		  ]
		  markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: kb)
      
      if message.text == 'Price'
		    bot.api.send_message(chat_id: message.chat.id, text: 'Please chose next step', reply_markup: markup)
	    end

	    buy(message, name_coin, @coin_price) if message.text == 'Buy'

	    coin(name_coin) if message.text == 'Back to previous step'
    	
    end
  end

  def buy(message, name_coin, coin_price)
    
    bot.listen do |message|
      coin = name_coin
      bot.api.send_message(chat_id: message.chat.id, text: 'Please write quantity coin that you wanna buy')
      if message.text.to_f > 0
        DBPG.new.add_coin_to_user(message.chat.first_name, message.chat.id, coin, message.text.to_f, coin_price)
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
