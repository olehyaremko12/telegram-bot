# frozen_string_literal: true

require_relative 'db_pg'

class Transaction

	def add_transaction(kind, coin, quantity, price, chat_id)
    last_transaction_id

    DBPG::CON.exec "INSERT INTO Transactions VALUES(#{last_id + 1},'#{kind}', '#{coin}', #{quantity}, #{price}, #{chat_id})"
  end

  private

  def last_transaction_id
    last_id = 0
    transactions = DBPG::CON.exec 'SELECT * FROM Transactions'
    binding.pry # <====== REMOVE ME!!!
    transactions.each do |row|
      id = row['id'].to_i
      binding.pry # <====== REMOVE ME!!!
      last_id = row['id'] if last_id < id
    end
  end
end
