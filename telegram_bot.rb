# frozen_string_literal: true

require 'telegram/bot'
require_relative 'crypto_bot_index'
require 'rest-client'
require 'json'
require 'pry'

class TelegramBot
  TOKEN = '1246743304:AAFY4X3KH0BxPPbL0UtIPGZf3ExvpW8FGH8'
  ARRCOIN = ['BTC', 'ETH', 'Xrp', 'BCH'].freeze

  def coin_message
    bot.listen do |message|
	  	kb = [
	    	Telegram::Bot::Types::KeyboardButton.new(text: 'Start', one_time_keyboard: true)
	    ]
	  	markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: kb)
	  	bot.api.send_message(chat_id: message.chat.id, text: 'Press the button start', reply_markup: markup)
	  	
	  	start() if message.text == 'Start'
    end
  end

  def start
    bot.listen do |message|
	  	kb = [
	    	Telegram::Bot::Types::KeyboardButton.new(text: 'BTC', one_time_keyboard: true),
	    	Telegram::Bot::Types::KeyboardButton.new(text: 'ETH', one_time_keyboard: true),
	    	Telegram::Bot::Types::KeyboardButton.new(text: 'Xrp', one_time_keyboard: true),
	    	Telegram::Bot::Types::KeyboardButton.new(text: 'BCH', one_time_keyboard: true),
	    	Telegram::Bot::Types::KeyboardButton.new(text: 'Home', one_time_keyboard: true)
	    ]
	  	markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: kb)
	  	bot.api.send_message(chat_id: message.chat.id, text: 'Please chose coin', reply_markup: markup)
	  	
	  	coin(message.text) if ARRCOIN.include?(message.text)

	  	coin_message() if message.text == 'Home'
    end
  end

  def coin(currency)
    bot.listen do |message|
			name_coin = currency
	    kb = [
		   	Telegram::Bot::Types::KeyboardButton.new(text: 'Price', one_time_keyboard: true),
		   	Telegram::Bot::Types::KeyboardButton.new(text: 'Back to previous step', one_time_keyboard: true),
		  ]
		  markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: kb)
		  bot.api.send_message(chat_id: message.chat.id, text: 'Please chose next step', reply_markup: markup)
	   
	    price(message, name_coin) if message.text == 'Price'

	    start() if message.text == 'Back to previous step'
    end
  end

  def price(message, name_coin)
    bot.listen do |message|
  		url = 'https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest'
  		parameters = { 'X-CMC_PRO_API_KEY' => 'a003018f-63eb-45a0-80c0-6dfa69ab4b7f', 'start'=>'1', 'limit'=>'1', 'convert'=>"USD,#{name_coin}"}
  		coinmarket_api(message, url, parameters, name_coin)

	   	kb = [
		   	Telegram::Bot::Types::KeyboardButton.new(text: 'Buy', one_time_keyboard: true),
		   	Telegram::Bot::Types::KeyboardButton.new(text: 'Back to previous step', one_time_keyboard: true),
		  ]
		  markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: kb)
		  bot.api.send_message(chat_id: message.chat.id, text: 'Please chose next step', reply_markup: markup)
	   
	    buy(message, name_coin) if message.text == 'Buy'

	    start() if message.text == 'Back to previous step'
    	
    end
  end

  def buy(message, name_coin)
  	bot.listen do |message|
  		bot.api.send_message(chat_id: message.chat.id, text: 'Buy 000')
  	end
  end

  private

  def bot
    Telegram::Bot::Client.run(TOKEN) { |bot| return bot }
  end

  def coinmarket_api(message, url, parameters = {}, coin)
    response = RestClient.get(url, headers = parameters)
    parsed_response = JSON.parse(response)
    parsed_responce_data_arr = parsed_response['data']
    bitcoin_price = parsed_response['data'].map do |coin_param|
      next unless coin_param['name'] = coin

      @coin_price = coin_param['quote']['USD']['price'].to_i
      send_message(message.from.id, @coin_price)
      return
    end
  end

  def send_message(chat_id, message)
    bot.api.sendMessage(chat_id: chat_id, text: message)
  end
end
