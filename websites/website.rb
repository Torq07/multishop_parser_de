require 'nokogiri'
require 'open-uri'

class Website

	def parse_data; end
	def parse_brands; end
	def get_item_data; end

	def load_page(address)
	  url=URI(address)
		@page=Nokogiri::HTML.parse(open(url))	
	end

	def split_name(name)
		result=nil
		name.downcase!
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

end	