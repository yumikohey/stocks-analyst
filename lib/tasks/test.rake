namespace :test do
  desc "server testing"
	task test: :environment do
		time = Time.current.to_i.to_s
		(1..10).each do |i|
			open("test#{time}.txt", 'a') { |f|
				f.puts i
			}
		end
		require 'aws-sdk'
  	s3 = Aws::S3::Resource.new(region: 'us-west-1')
		File.open(Rails.root.join("test#{time}.txt"), 'r') do |file|
	  		obj = s3.bucket('stocks-analyst-data').object('test')
			obj.upload_file(file)
			puts "Uploaded '%s' to S3!" % 'test'
		end
  end

end
