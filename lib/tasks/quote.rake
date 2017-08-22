namespace :quote do
  desc "Collect daily quotes"
  task download_daily_quote: :environment do
    yahoo_client = YahooFinance::Client.new
    stocks = Stock.all()
    stocks.each do |stock|
      symbol = stock.symbol
      data = yahoo_client.quotes([symbol], [:open, :close, :low, :high, :volume] )
      check_quote_exist = Quote.where(symbol:symbol, date: Date.parse("2018-08-21"))
      if (check_quote_exist.length == 0)
        quote = Quote.new(symbol:symbol, open:data[0].open.to_f, close: data[0].close.to_f, low: data[0].low.to_f, high: data[0].high.to_f, volume: data[0].volume.to_i, date: Date.parse("2018-08-21"))
        quote.save!
        File.open("quote_updates_08212017.log", "a") { |f|
          f.puts "#{symbol}"
        }
      end
    end
    s3 = Aws::S3::Resource.new(region: 'us-west-1')
    File.open(Rails.root.join("quote_updates_08212017.log"), 'r') do |file|
      obj = s3.bucket('stocks-analyst-data').object('quote_updates_08212017.log')
      obj.upload_file(file)
      puts "Uploaded '%s' to S3!" % 'quote_updates_08212017.log'
    end
  end

end
