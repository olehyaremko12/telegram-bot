require 'rest-client'
require 'coinmarketcap'

class CryptoBotIndex
	attr_reader :coin

	API_URL = 'https://pro-api.coinmarketcap.com'.freeze
	API_KEY = 'a003018f-63eb-45a0-80c0-6dfa69ab4b7f'.freeze
	
	def initialize(coin)
	 @coin = coin
	end

	# def form_message
 # 		temperature.nil? ? 'City not found' : "In #{city} city today is #{temperature} celsius #{select_icon(temperature)}"
	# end

	def coin_market_url
		"#{API_URL}/cryptocurrency/"
	end

end