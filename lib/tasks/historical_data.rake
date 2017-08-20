namespace :historical_data do
	desc "Collect historical data"
	def collect_data (begin_date, end_date)
			time = Time.now.to_i.to_s
		  stocks = Stock.all()
			stocks.each do |stock|
			symbol = stock.symbol
				begin
					url = "https://finance.yahoo.com/quote/#{symbol}/history?period1=#{begin_date}&period2=#{end_date}&interval=1d&filter=history&frequency=1d"				
					page = Nokogiri::HTML(open(url))
					table = page.css("table[data-test=historical-prices]")
					count = table.css('tr').length
					if count > 2
						(1..count-2).each do |i|
							number_of_cells = (table.css('tr')[i]).children.length
							if number_of_cells == 7
								date = Date.parse(((table.css('tr')[i]).css('td')[0]).css('span').text)
								open = (((table.css('tr')[i]).css('td')[1]).css('span').text).to_f
								high = (((table.css('tr')[i]).css('td')[2]).css('span').text).to_f
								low = (((table.css('tr')[i]).css('td')[3]).css('span').text).to_f
								close = (((table.css('tr')[i]).css('td')[4]).css('span').text).to_f
								volume = (((table.css('tr')[i]).css('td')[6]).css('span').text).tr(',', '').to_i
								check_quote = Quote.where(symbol:symbol, date:date)
								if open == 0.0
									open("stocks#{time}.log", 'a') { |f|
										f.puts symbol
										f.puts "****************"
										f.puts table.css('tr')[i]
										f.puts "****************"
									}
								elsif check_quote.length === 1
									puts "#{symbol}, #{date} written in DB already"
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
								open("split#{time}.txt", 'a') { |f|
									f.puts "#{symbol}, #{date}, #{content}"
									f.puts "****************"
								}
							else
								open("exceptions#{time}.log", 'a') { |f|
									f.puts symbol
									f.puts "****************"
									f.puts table.css('tr')[i]
									f.puts "****************"
								}
							end
						end
					else
						open("entries#{time}.txt", 'a') { |f|
							f.puts "#{symbol} is a new stock  "
						}
					end
				rescue => e
					open("error#{time}.log", 'a') { |f|
						f.puts symbol
						f.puts "****************"
					}
				end
			open("entries#{time}.txt", 'a') { |f|
				f.puts "#{symbol}"
			}
		end
		require 'aws-sdk'
		["stocks#{time}.log", "split#{time}.txt", "exceptions#{time}.log", "entries#{time}.txt", "error#{time}.log"].each do |file_name|
			if File.exist?(file_name)
				s3 = Aws::S3::Resource.new(region: 'us-west-1')
				File.open(Rails.root.join(file_name), 'r') do |file|
						obj = s3.bucket('stocks-analyst-data').object(file_name)
					obj.upload_file(file)
					puts "Uploaded '%s' to S3!" % file_name
				end
			end
		end
	end

  task collect_historical_data: :environment do
		require 'nokogiri'
		stocks = Stock.all
		date_ranges = [
			{
				begin_date: '1484719200', # 1/18/2017
				end_date: '1495083600' # 5/18/2017
			},
			{
				begin_date: '1472706000', # 9/1/2016
				end_date: '1484632800' # 1/17/2016
			}
		]
		date_ranges.each do |element|
			begin_date = element[:begin_date]
			end_date = element[:end_date]
			collect_data(begin_date, end_date)
		end
  	# symbol = 'TSLA'
  	# url = "https://finance.yahoo.com/quote/#{symbol}/history?period1=1495170000&period2=1503118800&interval=1d&filter=history&frequency=1d"
  end
end
