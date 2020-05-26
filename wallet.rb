# frozen_string_literal: true

require_relative 'db_pg'

class Wallet

	def buy_coin(coin, quantity, chat_id)
    last_wallet_id

    DBPG::CON.exec "INSERT INTO Users VALUES(#{last_id + 1}, '#{coin}', #{quantity},  #{chat_id} )"
	end

	private

  def last_wallet_id
    last_id = 0
    wallet = DBPG::CON.exec 'SELECT * FROM Wallets'
    wallet.each do |row|
      id = row['id'].to_i
      
      last_id = row['id'] if last_id < id
    end
  end
end
