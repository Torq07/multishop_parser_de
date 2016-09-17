require_relative 'website'

class Vandenborre < Website

	attr_reader :endpoint
	attr_accessor :page,:categories_links, :item_data, :exceptions, :brands

	ENDPOINT='http://www.vandenborre.be'

	def initialize
		@categories_links=[]
		@item_data=[]
		@exceptions=[ 'GSM / Smartphone',
								  'Printer - Scanner',
								  'Videoprojector',
								  'Digitaal fototoestel - Camera',
									'Decoder digitale televisie',
									'Dictafoon',
									'Smart Home',
									'Inbouwtoestel',
									'Kookplaat',
									'Dampkap',
									'Kookpot - Kookpan - Keukengerei',
									'Vaatwasser',
									'Babyartikelen',
									'Openlucht - Trekking',
									'Sfeer - Gifts - Drankverdeler',
									'Computer - Laptop',
									'Harde schijf - Mediaplayer',
									'Multimedia service',
									'Tablet - E-reader',
									'Scherm - Muis - Toetsenbord',
									'Software',
									'Gaming - Spelconsole',
									'Netwerk - Wifi - Mobiel internet',
									'Digitaal fototoestel - Camera',
									'Vaste telefonie',
									'Diensten en Prepaid',
									'Mobiel internet',
									'Hoesje en screenprotection',
									'Computer - Laptop - Tablet pc',
									'Printer',
									'Smartphonehoesje'
								]
	end
	
	def parse_data
		load_page(ENDPOINT)
		page.css('div.grid_2.univLinkBlock.alpha h3 a').each do |a|
			load_page("http:#{a['href']}")
			page.css('div.universElement').each do |block|
				block.css('ul li a').each do |a|
					categories_links<<"http:#{a['href']}" unless a.text=='Andere'
				end	unless exceptions.include?(block.at('h3 a span').text)
			end	
		end	
		get_item_data
	end

	def parse_brands
		@brands=page.css('div.info_merk.info ul li label').map{|a| a.text.strip.downcase }
		@brands.shift
		@brands+=["fresh ´n rebel","silk´n","vogel´s"]
	end

	def get_item_data
		categories_links.each do |link|
			load_page(link)
			brands=parse_brands
			puts link
			page.css('li.productline.Normal div.product').each do |product|
				product_name=product.css('div.prod_naam h2 a').text.downcase
				properties=split_name(product_name)
				item_data<<[properties[0].capitalize,
										 properties[1].upcase,
										 product.css('div.prijs strong').text]

			end																								 
		end	
		item_data
	end	
		

end	
