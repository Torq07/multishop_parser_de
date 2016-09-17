require_relative 'website'

class Artencraft < Website

	attr_reader :endpoint
	attr_accessor :page,:categories_links, :item_data, :exceptions, :brands

	ENDPOINT='https://www.artencraft.be'

	def initialize
		@categories_links=[]
		@item_data=[]
		@exceptions=['']
	end

	def parse_data
		load_page(ENDPOINT)
		page.css('ul.large-menu li a.first').each	 do |a|
			@categories_links<<ENDPOINT+a['href']
		end
		get_item_data
	end

	def parse_brands
		@brands=page.at('strong:contains("Merk")')
			.next.next.css('li input')
			.map{ |e| e['value'].downcase } 
	end

	def get_item_data
		categories_links.uniq.each do |category|
			p category
			load_page(category)
			parse_brands
			page_amount=page.css('nav.pager ul li a')[-2].text[/\d+/].to_i
			(1..page_amount).each do |index|
				begin		
					load_page(category+"?page=#{index}")
					page.css('ul.product-overview li div.product-data-top-wrap').each do |item|
						properties=split_name(item.at('strong.product-name').text)
						properties<<item.at('strong.product-price').text.strip
						item_data<<properties
					end
				rescue
					next
				end
			end
		end
		item_data
	end


end
 