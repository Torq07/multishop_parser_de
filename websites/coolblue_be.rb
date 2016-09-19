require_relative 'website'

class Coolblue < Website

	attr_reader :endpoint
	attr_accessor :page,:categories_links, :item_data, :exceptions, :brands

	ENDPOINT='https://www.coolblue.be/ons-assortiment'

	def initialize
		@categories_links=[]
		@item_data=[]
		@exceptions=['smartphones','gsm\'s']
	end

	def parse_data
		load_page(ENDPOINT)
		page.css('a.category-navigation--link.js-category-link').each	 do |a|
			unless exceptions.include?(a.text.strip.downcase)
				@categories_links<<a['href']
			end
		end
		get_item_data
	end

	def parse_brands
			@brands=page.at('h3:contains("Merk")')
				.next.next.css('li label')
				.map{ |e| e['title'].downcase }
	end	
			
	def get_item_data
		p categories_links.count
		categories_links.uniq.each do |link|
			begin
				p link
				load_page(link)
				item_amount=page.at('span.paging-options-products strong[3]')
												.text[/(\d+)/]
												.to_i
				page_amount=item_amount/150
				page_amount=page_amount.succ unless item_amount%150==0
				brands=parse_brands
				(1..page_amount).each do |index|
					begin
						load_page(link+"?items=150&page=#{index}")
						page.css('div.product-item--block.product-item--block-details').each do |item|
							name=split_name(item.at('div h2 a').text.strip)
							unless name.nil?
								price=item.at('strong[itemprop="price"]')['content']
								properties=name
								properties<<price
								item_data<<properties
							end
						end
						rescue
							next
						end
				end
			rescue
				next		
			end	
		end
		item_data
	end

end