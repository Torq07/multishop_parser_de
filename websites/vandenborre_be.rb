require 'nokogiri'
require 'open-uri'

class Vandenborre

	attr_reader :endpoint, :categories_links, :item_links, :exceptions	
	attr_accessor :page

	ENDPOINT='http://www.vandenborre.be/'

	def initialize
		@categories_links=[]
		@item_links=[]
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
	
	def load_page(address)
	  url=URI(address)
		@page=Nokogiri::HTML.parse(open(url))	
	end

	def get_categories_links
		load_page(ENDPOINT)
		page.css('div.grid_2.univLinkBlock.alpha h3 a').each do |a|
			load_page("http:#{a['href']}")
			page.css('div.universElement').each do |block|
				block.css('ul li a').each do |a|
					categories_links<<"http:#{a['href']}" unless a.text=='Andere'
				end	unless exceptions.include?(block.at('h3 a span').text)
			end	
		end	
		get_item_links
	end

	def get_item_links
		categories_links.each do |link|
			puts link
			load_page(link)
			page.css('li.productline.Normal div.product').each do |product|
			 item_links<<[product.css('div.prod_naam h2 a').text,
									  product.css('div.prijs strong').text]
			end																								 
		end	
		item_links
	end	
		

end	
