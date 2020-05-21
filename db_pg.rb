require 'pg'

class DBPG
	def connect
		begin
			db_credential
			
			# @con.exec "DROP TABLE IF EXISTS Users"
			# @con.exec "CREATE TABLE Users(Id INTEGER PRIMARY KEY, 
			#     Name Text, ID_Telegram_User INT, Coin Text, Quantity VARCHAR(20), Price_usd VARCHAR(20))"

			rs = @con.exec "SELECT * FROM Users"
			rs.each do |row|
			  puts row
			end
		rescue PG::Error => e

			puts e.message 
			
		ensure

			@con.close if @con
			
		end
	end

	def add_coin_to_user(name_user, chat_id, coin, quantity, price)
		db_credential
		@con.exec "INSERT INTO Users VALUES(2, '#{name_user}', #{chat_id}, '#{coin}', #{(quantity).to_f} , #{price} )"
	end

	private

	def db_credential
		@con = PG.connect :dbname => 'botdb', :user => 'oleg'
	end
end
DBPG.new.connect()
