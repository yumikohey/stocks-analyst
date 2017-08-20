namespace :initdb do
  desc "write stock companies information into database"
  task write_stocks_in_db: :environment do
  	require 'csv'
 #  	count = 0
 #  	CSV.foreach("lib/assets/data/nasdaq.csv", {:headers=>:first_row}) do |row|
 #  		symbol = row[0]
 #  		company_name = row[1].tr('"', '')
 #  		stock_exchange = 'nasdaq'
 #  		ipo_year = row[5]
 #  		sector = row[6]
 #  		industry = row[7]
 #  		stock = Stock.new(symbol: symbol, company_name: company_name, stock_exchange: stock_exchange, ipo_year: ipo_year, sector: sector, industry: industry)
 #  		stock.save!
 #  		count += 1
 #  		puts symbol, count
	# end
	# count = 0
 #  	CSV.foreach("lib/assets/data/nyse.csv", {:headers=>:first_row}) do |row|
 #  		symbol = row[0]
 #  		company_name = row[1].tr('"', '')
 #  		stock_exchange = 'nyse'
 #  		ipo_year = row[5]
 #  		sector = row[6]
 #  		industry = row[7]
 #  		stock = Stock.new(symbol: symbol, company_name: company_name, stock_exchange: stock_exchange, ipo_year: ipo_year, sector: sector, industry: industry)
 #  		stock.save!
 #  		count += 1
 #  		puts symbol, count
	# end

	count = 0
  	CSV.foreach("lib/assets/data/amex.csv", {:headers=>:first_row}) do |row|
  		symbol = row[0]
  		company_name = row[1].tr('"', '')
  		stock_exchange = 'amex'
  		ipo_year = row[5]
  		sector = row[6]
  		industry = row[7]
  		stock = Stock.new(symbol: symbol, company_name: company_name, stock_exchange: stock_exchange, ipo_year: ipo_year, sector: sector, industry: industry)
  		stock.save!
  		count += 1
  		puts symbol, count
	end

	count = 0
	CSV.foreach("lib/assets/data/ETFList.csv", {:headers=>:first_row}) do |row|
  		symbol = row[0]
  		company_name = row[1].tr('"', '')
  		stock_exchange = 'etf'
  		stock = Stock.new(symbol: symbol, company_name: company_name, stock_exchange: stock_exchange)
  		stock.save!
  		count += 1
  		puts symbol, count
	end

  end

end
