require 'pg'

begin

    con = PG.connect :dbname => 'botdb', :user => 'oleg'
    
    # con.exec "DROP TABLE IF EXISTS Users"
    # con.exec "CREATE TABLE Users(Id INTEGER PRIMARY KEY, 
    #     Name VARCHAR(20), ID_Telegram_User INT, Coin VARCHAR(20), Quantity VARCHAR(20), Price_usd VARCHAR(20))"
    # con.exec "INSERT INTO Users VALUES(1,'Oleg',022222222, 'btc', 2 , 111)"

    rs = con.exec "SELECT * FROM Users"
    rs.each do |row|
      puts row
    end
rescue PG::Error => e

    puts e.message 
    
ensure

    con.close if con
    
end