module FormThirteensHelper
    @@filed_date = Date.parse("2017-08-14")
    @@time = Time.now.to_datetime.to_s

    def self.set(filed_date, time)
        @@filed_date = filed_date
        @@time = time
    end

    def navigate_to_a_page(url)
        puts "**********************************"
        puts "#{url}"
        puts "**********************************"
        return Nokogiri::HTML(open(url))
    end

    def save_institution(company_name, cik, file_number, state, address)
        institution = Institution.new(name: company_name, cik:cik, file_number:file_number, state:state, address: address)
        institution.save!
        file_name = "#{Rails.env}_new_institution_#{@@time}.log"
        write_log_file(file_name, institution.name, " saved")
    end

    def write_log_file(file_name, *params)
        File.open(file_name, "a") { |f|
            f.puts params
        }
    end

    def goto_the_form(second_table, company_name, file_number)
        host = "https://www.sec.gov/"
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
                form = FormThirteen.new(filed_date:@@filed_date, form_type: "13F-HR", file_number: file_number, name_of_issue: issuer, title_of_class: title_class, cusip:cusip, value:value, shares_or_principle_amt: shares_or_principle_number, shares_or_principle:shares_or_principle, put_or_call:put_or_call, investment_desc:investment_discretion, other_manager:other_manager,sole_number:sole, shared_number:shared, none_number:none)
                form.save!
            end
            thirteen_form_filename = "#{Rails.env}_thirteen_form_#{@@time}.log"
            write_log_file(thirteen_form_filename, company_name, @@filed_date)
        end
        puts "goto #{company_name} done"
    end

    def goto_institution_form_page(table, count)
        host = "https://www.sec.gov/"
        (1..count).each do |idx|
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
            forms_not_saved = true
            if saved_institution.length == 0
                save_institution(company_name, cik, file_number, state, address)
            else
                saved_forms = FormThirteen.where(file_number:file_number, filed_date:@@filed_date).count()
                forms_not_saved = saved_forms == 0
            end
            if forms_not_saved
                goto_the_form(second_table, company_name, file_number)
            end
        end
        puts "goto institution form page done"
    end

    def scrape_multiple_page(webpage)
        host = "https://www.sec.gov/"
        table = webpage.css("div > table")
        number_of_pages = (webpage.css("div > center")[0]).css("a").length
        (0..number_of_pages-1).each do |index|
            if index != 0
                next_page_url = (webpage.css("div > center")[0]).css("a")[index-1]["href"]
                next_page = navigate_to_a_page(host + next_page_url)
                table = next_page.css("div > table")
            end
            goto_institution_form_page(table, 80)
        end
    end
end
