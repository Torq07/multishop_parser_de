require_relative 'websites/vandenborre_be'
require 'axlsx'
require 'gmail'

gmail = Gmail.connect('updatesenderbot@gmail.com', 'Cat12345')

vandenborre_shop=Vandenborre.new
#vandenborre_items=vandenborre_shop.get_categories_links
#Axlsx::Package.new do |p|
#	p.workbook.add_worksheet(:name => "Pie Chart") do |sheet|
#		sheet.add_row ["Product name",'Price']
#		vandenborre_items.each {|record| sheet.add_row record}
#	end
#	p.serialize('vandenborre.xlsx')
#end
gmail.deliver do
		to "torq07@gmail.com"
		subject "Update for #{Time.now}"
		text_part do
			body "Update is attached"
		end
		add_file "vandenborre.xlsx"
end
