# frozen_string_literal: true

require 'pg'
require 'pry'

# database class
class DBPG
  CON = PG.connect dbname: 'botdb', user: 'oleg'
  # CON = PG.connect dbname: 'dbtest', user: 'alex', password: 'alex'

  def create_table
    DBPG::CON.exec('CREATE TABLE Users(User_Id INTEGER PRIMARY KEY,
      Name Text, Create_At TIMESTAMP);')

    DBPG::CON.exec("CREATE TABLE Transactions(Id INTEGER PRIMARY KEY,
      Kinds Text, Coin Text, Quantity NUMERIC, Price_usd NUMERIC,
      Create_At TIMESTAMP, User_Id INTEGER NOT NULL REFERENCES Users(User_Id));")

    DBPG::CON.exec("CREATE TABLE Wallets(Id INTEGER PRIMARY KEY,
      Coin Text, Quantity NUMERIC, Create_At TIMESTAMP, User_Id INTEGER NOT NULL REFERENCES Users(User_Id));")
  end

  def drop_db
    DBPG::CON.exec 'DROP TABLE IF EXISTS Wallets'
    DBPG::CON.exec 'DROP TABLE IF EXISTS Transactions'
    DBPG::CON.exec 'DROP TABLE IF EXISTS Users'
  end

  def insert_users(chat_id, name_user)
    DBPG::CON.exec "INSERT INTO Users VALUES( #{chat_id}, '#{name_user}', '#{Time.now}')"
  end

  def insert_wallets(id, name_coin, quantity, chat_id)
    DBPG::CON.exec "INSERT INTO Wallets VALUES(#{id}, '#{name_coin}', #{quantity}, '#{Time.now}', #{chat_id} )"
  end

  def insert_transactions(id, kind, coin, quantity, price, chat_id)
    DBPG::CON.exec "INSERT INTO Transactions VALUES( #{id},
    '#{kind}', '#{coin}', #{quantity}, #{price}, '#{Time.now}', #{chat_id})"
  end

  def show_all
    users = DBPG::CON.exec 'SELECT * FROM Users'
    users.each do |row|
      puts row
    end
    puts '------------------------------'
    transactions = DBPG::CON.exec 'SELECT * FROM Transactions'
    transactions.each do |row|
      puts row
    end
    puts '------------------------------'
    wallet = DBPG::CON.exec 'SELECT * FROM Wallets'
    wallet.each do |row|
      puts row
    end
  end
end
# DBPG.new.drop_db
# DBPG.new.create_table
DBPG.new.show_all
