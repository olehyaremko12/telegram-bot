require 'telegram/bot'
require_relative 'crypto_bot_index'
require 'rest-client'
require 'json'
require 'pry'

class TelegramBot
	TOKEN = '1246743304:AAFY4X3KH0BxPPbL0UtIPGZf3ExvpW8FGH8'.freeze
	ARRCOIN = ["Bitcoin", "Ethereum", "Xrp" "Bitcoin Cash"]

	def run(method_name, coin = 'coin')
		bot.listen do |message|
			if(method_name == 'first')
				coin_message(message)
			end
			if(method_name == 'start')
				start(message)
			end

			if(method_name == 'coin')
				coin(message)
			end

			if(method_name == 'price')
				price(message, coin)
			end
		rescue => e
		  puts e.message
		end
	end

	def coin_message(message)
		bot.api.send_message(chat_id: message.chat.id, text: "Press the button start, #{message.from.first_name}")
		start_btn = Telegram::Bot::Types::ReplyKeyboardMarkup
		      				.new(keyboard: [%w(Start)], one_time_keyboard: true, reply_markup: run('start'))
	end

	def start(message)
		if message.text == 'Start'
			bot.api.send_message(chat_id: message.chat.id, text: "Please chose coin, #{message.from.first_name}")
	    coin_btn =Telegram::Bot::Types::ReplyKeyboardMarkup
	      				.new(keyboard: [%w(Bitcoin Ethereum), %w(Xrp Bitcoin Cash), %w(Home)], one_time_keyboard: true, reply_markup: run('coin'))
		end
	end

	def coin(message)
		if ARRCOIN.include?(message.text)
			binding.pry # <====== REMOVE ME!!!
		end
	end


	private

	def bot
 		Telegram::Bot::Client.run(TOKEN) { |bot| return bot }
	end

	def coinmarket_api(message, url, parameters = {}, coin)
		# url = 'https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest'

		response = RestClient.get(url, headers = parameters)
		parsed_response = JSON.parse(response)
		parsed_responce_data_arr = parsed_response['data']
		bitcoin_price = parsed_response['data'].map do |coin_param|
			if coin_param['name'] = coin
				@coin_price = coin_param['quote']['USD']['price'].to_i
				send_message(message.from.id, @coin_price)
				return
			end
		end
	end

	def send_message(chat_id, message)
    	bot.api.sendMessage(chat_id: chat_id, text: message)
  end

end

