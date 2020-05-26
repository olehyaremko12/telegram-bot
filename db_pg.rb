# frozen_string_literal: true

require 'pg'
require 'pry'

class DBPG

	CON = PG.connect dbname: 'botdb', user: 'oleg'

  def connect
  	# DBPG::CON.exec "DROP TABLE IF EXISTS Wallets"
  	# DBPG::CON.exec "DROP TABLE IF EXISTS Transactions"
  	# DBPG::CON.exec "DROP TABLE IF EXISTS Users"

  	# DBPG::CON.exec "CREATE TABLE Users(User_Id INTEGER PRIMARY KEY,
   #    Name Text, ID_Telegram_User INT)"

   #  DBPG::CON.exec "CREATE TABLE Transactions(Id INTEGER PRIMARY KEY,
   #    Kinds Text, Coin Text, Quantity VARCHAR(20), Price_usd VARCHAR(20), User_Id INTEGER NOT NULL REFERENCES Users(User_Id))"

   #  DBPG::CON.exec "CREATE TABLE Wallets(Id INTEGER PRIMARY KEY,
   #    Coin Text, Quantity VARCHAR(20), User_Id INTEGER NOT NULL REFERENCES Users(User_Id))"
  rescue PG::Error => e
    puts e.message
  ensure
    DBPG::CON&.close
  end

  # def db_credential
  # 	@con = PG.connect dbname: 'botdb', user: 'oleg'
  # end
end
# DBPG.new.connect
