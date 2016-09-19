Dir["./websites/*"].each {|file| require file }
require 'axlsx'
require 'gmail'


gmail = Gmail.connect(ENV['sender_email'], ENV['sender_pass'])

shops=['coolblue','vandenborre','plasmavisie','artencraft','kieskeurig']
shops.each do |shop|
	p shop
	code=%Q{
		#{shop}_shop=#{shop.capitalize}.new
		#{shop}_items=#{shop}_shop.parse_data
		Axlsx::Package.new do |p|
			p.workbook.add_worksheet(:name => "#{shop}") do |sheet|
				sheet.add_row ['Brand','Ref number','Price']
				#{shop}_items.each {|record| sheet.add_row record}
			end
			p.serialize("#{shop}.xlsx")
		end
	}
	eval code
end	

 gmail.deliver do
		to ENV['reciever_email']
		subject "Update"
		text_part do
			body "Update is attached"
		end
		shops.each {|shop| add_file "#{shop}.xlsx" }
end
