# frozen_string_literal: true

require 'rest-client'
require 'coinmarketcap'

require_relative 'telegram_bot'

class CryptoBotIndex
  API_KEY = 'a003018f-63eb-45a0-80c0-6dfa69ab4b7f'
  URL_LATEST = 'https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest'

  def self.coinmarket_api(message, parameters = {}, coin)
    response = RestClient.get(URL_LATEST, headers = parameters)
    parsed_response = JSON.parse(response)
    parsed_responce_data_arr = parsed_response['data']

    bitcoin_price = parsed_response['data'].map do |coin_param|
      next unless coin_param['symbol'] == coin

      @coin_price = coin_param['quote']['USD']['price'].to_f
      TelegramBot.new.send_message(message.from.id, @coin_price)
      return @coin_price
    end
  end
end
