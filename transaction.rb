# frozen_string_literal: true

require_relative 'db_pg'

class Transaction

	def add_transaction(kind, coin, quantity, price, chat_id)
    last_transaction_id

    DBPG::CON.exec "INSERT INTO Transactions VALUES( #{@last_id + 1},'#{kind}', '#{coin}', #{quantity}, #{price}, #{chat_id})"
  end

  private

  def last_transaction_id
    transactions = DBPG::CON.exec 'SELECT * FROM Transactions'
    @last_id = 0
    transactions.each do |row| 
      @last_id = row['id'].to_i
    end
  end
end
