require_relative 'db_pg'

class User

	def add_user(name_user, chat_id)
    uniq_user_id(chat_id)

    if @uniq
      DBPG::CON.exec "INSERT INTO Users VALUES( #{chat_id}, '#{name_user}')"
      DBPG::CON.exec "INSERT INTO Wallets VALUES(1, 'Point', 10000, #{chat_id} )"
      DBPG::CON.exec "INSERT INTO Transactions VALUES( 1, 'first start', 'Point', 10000, 1, #{chat_id})"
    end
  end

  private

  def uniq_user_id(id)
    users = DBPG::CON.exec 'SELECT * FROM Users'
    @uniq = true
    
    users.each do |row|
      if row['user_id'].to_i == id
        @uniq = false
      end
    end
  end
end