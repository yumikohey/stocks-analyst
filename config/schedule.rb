# Use this file to easily define all of your cron jobs.
set :environment, "production"
set :output, {:error => "log/cron_error_log.log", :standard => "log/cron_log.log"}

# every :day, :at => '10:40pm' do
#     rake "historical_data:collect_historical_data"
# end

every :day, :at => '4:40pm' do
    rake "collect_sec_form:thirteen_form"
end

# every :day, :at => '6:05am' do
#     rake "quote:download_daily_quote"
# end
