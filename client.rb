require_relative 'websites/vandenborre_be'
require_relative 'websites/plasmavisie_be'
require_relative 'websites/kieskeurig_be'
require 'axlsx'
require 'gmail'

gmail = Gmail.connect('updatesenderbot@gmail.com', 'Cat12345')

shops=['vandenborre','plasmavisie','kieskeurig']
shops.each do |shop|
	p shop
	code=%Q{
		#{shop}_shop=#{shop.capitalize}.new
		#{shop}_items=#{shop}_shop.get_categories_links
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
		to "torq07@gmail.com"
		# to "nicolas.sonck@electrostock.be"
		subject "Update for #{Time.now}"
		text_part do
			body "Update is attached"
		end
		shops.each {|shop| add_file "#{shop}.xlsx" }
end
