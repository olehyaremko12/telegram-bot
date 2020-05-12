# frozen_string_literal: true

require 'rest-client'
require 'coinmarketcap'

class CryptoBotIndex
  attr_reader :coin

  API_URL = 'https://pro-api.coinmarketcap.com'
  API_KEY = 'a003018f-63eb-45a0-80c0-6dfa69ab4b7f'

  def initialize(coin)
    @coin = coin
  end

  def coin_market_url
    "#{API_URL}/cryptocurrency/"
  end
end
