namespace :collect_sec_form do
  desc "Collect 13F-HR forms"
  task thirteen_form: :environment do
    host = "https://www.sec.gov/"
    filed_date = Date.parse("2017-08-21")
    form_type = "13F-HR"
    start_year = "2016"
    end_year = "2017"
    (1..10).each do |page|
      formatted_filed_date = filed_date.strftime("%m/%d/%Y")
      url = "https://www.sec.gov/cgi-bin/srch-edgar?text=#{CGI.escape(formatted_filed_date)}+and+#{CGI.escape(form_type)}&first=#{start_year}&last=#{end_year}"				
      page = Nokogiri::HTML(open(url))
      table = page.css("div > table")
      count = table.css('tr').length
      new_institution_count = 0
      time = Time.now.to_datetime.to_s
      if count > 2
        (1..count-1).each do |idx|
          company_name = ((table.css('tr')[idx]).css('td')[1]).css('a').text
          text_url = ((table.css('tr')[idx]).css('td')[2]).css('a')[1]['href']
          filed_date = Date.strptime(((table.css('tr')[idx]).css('td')[4]).text, "%m/%d/%Y")
          sub_page = Nokogiri::HTML(open(host+text_url))
          second_table = sub_page.css("#contentDiv #formDiv")[1]
          company_identity = sub_page.css('#filerDiv')
          cik = company_identity.css('.companyName a').text.split(' (see')[0]
          file_number =  company_identity.css('.identInfo a strong').text
          state = (company_identity.css('.identInfo strong')[1]).text
          address = (company_identity.css('.mailer')[1]).css('.mailerAddress').text.split(" ").join(" ")
          saved_institution = Institution.where(cik:cik)
          if saved_institution.length == 0
            institution = Institution.new(name: company_name, cik:cik, file_number:file_number, state:state, address: address)
            institution.save!
            new_institution_count += 1
            puts "#{institution.name} #{new_institution_count}"
            File.open("new_institution_#{time}.log", "a") { |f|
              f.puts "#{institution.name} #{new_institution_count}"
            }
          end
          form_html = ((second_table.css('tr')[3]).css('td')[2]).css('a')[0]['href']
          form_page = Nokogiri::HTML(open(host+form_html))
          form_table = form_page.css("table")[3]
          items_count = form_table.css("tr").length
          if items_count > 3
            (3..items_count-1).each do |row|
              issuer = (form_table.css("tr")[row]).css("td")[0].text
              title_class = (form_table.css("tr")[row]).css("td")[1].text
              cusip = (form_table.css("tr")[row]).css("td")[2].text
              value = (form_table.css("tr")[row]).css("td")[3].text.tr(',', '').to_i
              shares_or_principle_number = (form_table.css("tr")[row]).css("td")[4].text.tr(',', '').to_i
              shares_or_principle = (form_table.css("tr")[row]).css('td')[5].text
              put_or_call = (form_table.css("tr")[row]).css("td")[6].text
              investment_discretion = (form_table.css("tr")[row]).css("td")[7].text
              other_manager = (form_table.css("tr")[row]).css("td")[8].text
              sole = (form_table.css("tr")[row]).css("td")[9].text.tr(',', '').to_i
              shared = (form_table.css("tr")[row]).css("td")[10].text.tr(',', '').to_i
              none = (form_table.css("tr")[row]).css("td")[11].text.tr(',', '').to_i
              form = FormThirteen.new(filed_date:filed_date, form_type: "13F-HR", file_number: file_number, name_of_issue: issuer, title_of_class: title_class, cusip:cusip, value:value, shares_or_principle_amt: shares_or_principle_number, shares_or_principle:shares_or_principle, put_or_call:put_or_call, investment_desc:investment_discretion, other_manager:other_manager,sole_number:sole, shared_number:shared, none_number:none)
              form.save!
            end
            puts "#{company_name} #{filed_date}"
            File.open("thirteen_form_#{time}.log", "a") { |f|
              f.puts "#{company_name} #{filed_date}"
            }
          end
  
        end
  
      end
      require 'aws-sdk'
      ["new_institution_#{time}.log","thirteen_form_#{time}.log"].each do |file_name|
        if File.exist?(file_name)
          s3 = Aws::S3::Resource.new(region: 'us-west-1')
          File.open(Rails.root.join(file_name), 'r') do |file|
              obj = s3.bucket('stocks-analyst-data').object(file_name)
            obj.upload_file(file)
            puts "Uploaded '%s' to S3!" % file_name
          end
        end
      end
      
      loop do
        filed_date -= 1
        if filed_date.saturday? or filed_date.sunday?
          filed_date -= 1
        else 
          break
        end
      end

    end

  end

end
