# frozen_string_literal: true

require 'rest-client'
require 'coinmarketcap'

require_relative 'telegram_bot'

# connect to coinmarketcap api
class CryptoBotIndex
  API_KEY = 'a003018f-63eb-45a0-80c0-6dfa69ab4b7f'
  URL_LATEST = 'https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest'

  def coinmarket_api(message, coin, parameters = {})
    response = RestClient.get(URL_LATEST, parameters)
    parsed_response = JSON.parse(response)

    parsed_response['data'].map do |coin_param|
      next unless coin_param['symbol'] == coin

      @coin_price = coin_param['quote']['USD']['price'].to_f
      TelegramBot.new.send_message(message.from.id, "Current price = #{@coin_price}")
      return @coin_price
    end
  end

  def parameter_api(message, name_coin)
    parameters = {
      'X-CMC_PRO_API_KEY' => CryptoBotIndex::API_KEY,
      'start' => '1',
      'limit' => '1',
      'convert' => "USD,#{name_coin}"
    }
    @coin_price = coinmarket_api(message, name_coin, parameters)
  end
end
