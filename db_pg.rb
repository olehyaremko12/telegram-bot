require 'pg'

class DBPG
	def connect
		begin
			db_credential
			
			# @con.exec "DROP TABLE IF EXISTS Users"
			# @con.exec "CREATE TABLE Users(Id INTEGER PRIMARY KEY, 
			#     Name Text, ID_Telegram_User INT, Coin Text, Quantity VARCHAR(20), Price_usd VARCHAR(20))"

			# rs = @con.exec "SELECT * FROM Users"
			# rs.each do |row|
			#   puts row
			# end

			# @con.exec "CREATE TABLE Users(User_Id INTEGER PRIMARY KEY, 
   #        Name Text, ID_Telegram_User INT)"
      
   #    @con.exec "CREATE TABLE Transactions(Id INTEGER PRIMARY KEY, 
   #        Kinds Text, Coin Text, Quantity VARCHAR(20), Price_usd VARCHAR(20), User_Id INTEGER NOT NULL REFERENCES Users(User_Id))"
      
   #    @con.exec "CREATE TABLE Wallets(Id INTEGER PRIMARY KEY, 
			#     Coin Text, Quantity VARCHAR(20), User_Id INTEGER NOT NULL REFERENCES Users(User_Id))"

		rescue PG::Error => e

			puts e.message 
			
		ensure

			@con.close if @con
			
		end
	end

	def add_coin_to_user(name_user, chat_id, coin, quantity, price)
		db_credential

		last_id = 0
		users = @con.exec "SELECT * FROM Users"
		users.each do |row|
			id = row["id"].to_i
			if last_id < id
				last_id = row["id"] 
			end	
		end
		
		# @con.exec "INSERT INTO Users VALUES(#{last_id + 1}, '#{name_user}', #{chat_id}, '#{coin}', #{(quantity).to_f} , #{price} )"
	end

	private

	def db_credential
		@con = PG.connect :dbname => 'botdb', :user => 'oleg'
	end
end
DBPG.new.connect()
