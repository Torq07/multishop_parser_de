require 'nokogiri'
require 'open-uri'

class Plasmavisie

	attr_reader :endpoint
	attr_accessor :page,:categories_links,:item_links, :brands

	ENDPOINT='https://www.plasmavisie.be'

	def initialize
		@categories_links=[]
		@item_links=[]
	end
	
	def load_page(address)
	  url=URI(address)
		@page=Nokogiri::HTML.parse(open(url))	
	end

	def get_categories_links
		load_page(ENDPOINT)
		accepted_cats=['Alle receivers','Alle kabels','Alle accessoires','Alle merken']
		@categories_links=page.css('div.navigatie ul.level0 li#categories-nav div.nav-content div.nav-content-block ul.level1 li ul li a')
												.select{ |link| accepted_cats.include?(link.text) }	
												.reject{ |link| link['href'].include?('av-meubelen')}
												.map{ |link| ENDPOINT+link['href'] }

		get_item_links		
	end

	def parse_brands
		@brands=page.at('dt:contains("Merk")').next.css('li a').map(&:text)
	end

	def split_name(name)
		result=nil
		brands.each do |brand| 
			if name.include?(brand)
				return [brand, name.partition(brand)[2]]
			else	
				array=name.split
				result||=[ array.shift, array.join(' ')] 
			end	
		end	
		result
	end		

	def get_item_links
		categories_links.each do |category|
			p category
			index=1
			load_page(category+"?p=#{index}")
			parse_brands
			begin
				load_page(category+"?p=#{index}")
				page.css('div.category-products ul.products-grid li.item').each do |item| 
					properties=split_name(item.css('h2.product-name a').text)
					properties<<item.css('div.price-box p.special-price span.price').first.text.strip
					properties
					item_links<<properties
				end	
				index+=1
			end until page.css('a.next.i-next').first.nil?
		end	
	  item_links
	end	
		

end	