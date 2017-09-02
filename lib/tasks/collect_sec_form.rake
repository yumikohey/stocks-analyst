namespace :collect_sec_form do
  desc "Collect 13F-HR forms"
  task thirteen_form: :environment do
    host = "https://www.sec.gov/"
		filed_date = Date.parse("2017-08-14")
		form_type = "13F-HR"
		start_year = "2016"
		end_year = "2017"
		time = Time.now.to_datetime.to_s
		include FormThirteensHelper
		(1..30).each do |page|
      puts "!!!!!!!!!!!!!!!!!!!!!!!!!"
      puts filed_date
      puts "!!!!!!!!!!!!!!!!!!!!!!!!!"
			formatted_filed_date = filed_date.strftime("%m/%d/%Y")
				url = "https://www.sec.gov/cgi-bin/srch-edgar?text=#{CGI.escape(formatted_filed_date)}+and+#{CGI.escape(form_type)}&first=#{start_year}&last=#{end_year}"
			puts url
				webpage = navigate_to_a_page(url)
				puts "returned;"
			table = webpage.css("div > table")
			count = table.css('tr').length
			has_multiple_pages = count == 82
			if has_multiple_pages
				puts "More than 80 institutions uploaded forms on #{filed_date}"
        FormThirteensHelper.set(filed_date, time)
				FormThirteensHelper.scrape_multiple_page(webpage)
			else
				puts "#{filed_date} only has one page."
        FormThirteensHelper.set(filed_date, time)
				FormThirteensHelper.goto_institution_form_page(table, count)
			end
			filed_date -= 1
			if filed_date.sunday?
				filed_date -= 2
			end
		end
    require 'aws-sdk'
    ["#{Rails.env}_new_institution_#{time}.log","#{Rails.env}_thirteen_form_#{time}.log"].each do |file_name|
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

end
