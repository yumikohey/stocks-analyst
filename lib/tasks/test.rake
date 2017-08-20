namespace :test do
  desc "server testing"
  task test: :environment do
  	(1..5).each do |i|
  		open("/var/log/stocks-data/test.log") {|f|
  			f.puts i
  		}
  	end
  end

end
