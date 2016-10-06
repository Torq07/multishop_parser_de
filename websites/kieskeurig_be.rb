require_relative 'website'

class Kieskeurig < Website

	attr_reader :endpoint
	attr_accessor :page,:categories_links, :item_data, :exceptions, :brands

	ENDPOINT='https://www.kieskeurig.be'

	def initialize
		@categories_links=[]
		@item_data=[]
		@exceptions=['mobiel','computers',
								 'fiets','gaming',
								 'baby_en_peuter','sport',
								 'cd','cameratas',
								 'koffer_en_reistas','dvd',
								 'fornuis','stoel',
								 'verlichting','bouw_en_constructiespeelgoed',
								 'pan','domotica','accessoires','Parfums']
	end

	def parse_data
		load_page(ENDPOINT)
		@categories_links+=['https://www.kieskeurig.be/robotstofzuiger','https://www.kieskeurig.be/thermostaat','https://www.kieskeurig.be/cv-ketel']
		page.search('div.sub-menu-cntr__menu ul.level-1').each	 do |a|
					unless exceptions.include?(a.at('a[1]').text.strip.downcase)
						a.search('ul[class="level-2"] li a').each do |a|
							@categories_links<<ENDPOINT+a['href'] if !exceptions.include?(a.text.strip)
						end
					end
		end
		get_item_data
	end

	def parse_brands
		@brands=page.css('ul.filter-search-results-list li')
								.reject{ |a| a['data-filter-label'].nil? }
								.map{|a| a['data-filter-label'] }
	end

	def get_item_data
		p categories_links.count
		categories_links.uniq.each do |link|
			p link
			load_page(link)
			item_amount=page.css('span.results.js-total-results')
											.text[/(\d+)/]
											.to_i
			page_amount=item_amount/23
			page_amount=page_amount.succ unless item_amount%23==0
			brands=parse_brands
			(1..page_amount).each do |index|
				begin
					load_page(link+"?page=#{index}")
					page.css('article.product-tile.js-product').each do |item|
						name=split_name(item.css('h2.product-tile__title').text.strip)
						unless name.nil?
							properties=name
							price=item.css('div.product-tile__price strong').text.strip ? item.css('div.product-tile__price strong').text.strip : "No price"
							puts item.css('h2.product-tile__title').text if properties.nil?
							properties<<price
							item_data<<properties
						end
					end
					rescue
						next
					end
			end
		end
		item_data
	end


end
