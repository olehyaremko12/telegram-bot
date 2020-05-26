require_relative 'db_pg'

class User

	def add_user(name_user, chat_id)
    last_user_id

    DBPG::CON.exec "INSERT INTO Users VALUES(#{last_id + 1}, '#{name_user}', #{chat_id} )"
    #chat_id must be uniq
  end

  private

  def last_user_id
    last_id = 0
    users = DBPG::CON.exec 'SELECT * FROM Users'
    users.each do |row|
      id = row['id'].to_i
      last_id = row['id'] if last_id < id
    end
  end
end