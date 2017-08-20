namespace :test do
  desc "server testing"
	task test: :environment do
		(1..5).each do |i|
			open('test.txt', 'a') { |f|
				f.puts i
			}
		end
		require 'aws-sdk'
  		s3 = Aws::S3::Resource.new(region: 'us-west-1')
		File.open(Rails.root.join('test.txt'), 'r') do |file|
	  		obj = s3.bucket('stocks-analyst-data').object('test')
			obj.upload_file(file)
			puts "Uploaded '%s' to S3!" % 'test'
		end
  end

end
