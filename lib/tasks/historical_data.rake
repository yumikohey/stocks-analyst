namespace :historical_data do
  desc "Collect historical data"
  task collect_historical_data: :environment do
		require 'nokogiri'
		stocks = Stock.where(stock_exchange:'nasdaq')
		stocks.each do |stock|
			symbol = stock.symbol
			url = "https://finance.yahoo.com/quote/#{symbol}/history?period1=1495170000&period2=1503118800&interval=1d&filter=history&frequency=1d"
			begin
				page = Nokogiri::HTML(open(url))
				table = page.css("table[data-test=historical-prices]")
				count = table.css('tr').length
				(1..count-1).each do |i|
					number_of_cells = (table.css('tr')[i]).children.length
					if number_of_cells == 7
						date = Date.parse(((table.css('tr')[i]).css('td')[0]).css('span').text)
						open = (((table.css('tr')[i]).css('td')[1]).css('span').text).to_f
						high = (((table.css('tr')[i]).css('td')[2]).css('span').text).to_f
						low = (((table.css('tr')[i]).css('td')[3]).css('span').text).to_f
						close = (((table.css('tr')[i]).css('td')[4]).css('span').text).to_f
						volume = (((table.css('tr')[i]).css('td')[6]).css('span').text).tr(',', '').to_i
						if open == 0.0
							open('stocks.log', 'a') { |f|
								f.puts symbol
								f.puts "****************"
								f.puts table.css('tr')[i]
								f.puts "****************"
							}
						else
							quote = Quote.new(symbol:symbol, date:date, open:open, high:high, close:close, low:low, volume:volume)
							quote.save!
							puts "#{symbol}, #{date}"
						end
					elsif number_of_cells == 2
						date = Date.parse(((table.css('tr')[i]).css('td')[0]).css('span').text)
						content = ((table.css('tr')[i]).css('td')[1]).css('span').text
						split = Split.new(symbol:symbol, date:date, content:content)
						split.save!
						open('split.txt', 'a') { |f|
							f.puts "#{symbol}, #{date}, #{content}"
							f.puts "****************"
						}
					else
						open('exceptions.log', 'a') { |f|
							f.puts symbol
							f.puts "****************"
							f.puts table.css('tr')[i]
							f.puts "****************"
						}
					end
				end
			rescue => e
				open('error.log', 'a') { |f|
					f.puts symbol
					f.puts "****************"
				}
			end
		end
  	# symbol = 'TSLA'
  	# url = "https://finance.yahoo.com/quote/#{symbol}/history?period1=1495170000&period2=1503118800&interval=1d&filter=history&frequency=1d"
  end
end
