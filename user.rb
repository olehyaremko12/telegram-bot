# frozen_string_literal: true

require_relative 'db_pg'

class User
  def add_user(name_user, chat_id)
    uniq_user_id(chat_id)

    if @uniq
      DBPG.new.insert_users(chat_id, name_user)
      DBPG.new.insert_wallets(1, 'Point', 10_000, chat_id)
      DBPG.new.insert_transactions(1, 'first start', 'Point', 10_000, 1, chat_id)
    end
  end

  private

  def uniq_user_id(id)
    users = DBPG::CON.exec 'SELECT * FROM Users'
    @uniq = true

    users.each do |row|
      @uniq = false if row['user_id'].to_i == id
    end
  end
end
