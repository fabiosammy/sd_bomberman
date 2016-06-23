# Encoding: UTF-8
require 'rubygems'
require 'gosu'
require_relative 'block'

#WIDTH, HEIGHT = 1750, 900
BLOCK_DIM = 64

class Map 
	
	#file = File.open("assets/images/cenarios/map1")
	#background_image = Gosu::Image.new("assets/images/cenarios/map3.bmp", :tileable => true)
	@file
	@width
	@height

	def initialize(map)	
		# pegar o arquivo, criar uma array de acordo com o arquivo	
		@file = File.open("assets/images/cenarios/#{map}") #unless file
		window = File.open("assets/images/cenarios/#{map}")
		@locals = []
		set_window_size window
		#@background_image = Gosu::Image.new("assets/images/cenarios/map0.bmp", :tileable => true) #unless background_image

		#metodo para identificar os caracteres do file
		generateBlocks @file
		

		#super @width-BLOCK_DIM, @height
		#self.caption = "BomberMANO"
    	#@client = Client.new(server, port)
    	
    	
	end

	def get_width
		@width-BLOCK_DIM
	end

	def get_heigth
		@height
	end

	def set_window_size file
		
		line = file.readlines
		@width = line[0].size*BLOCK_DIM
		@height = line.length*BLOCK_DIM
	end

	def generateBlocks file
		#adquire a quantidade de linhas de file(arquivo que foi lido)
		line = file.readlines
		linhas = line.length
		
		for j in (0..line.length- 1)
			#pega apenas a linha 
			each_line = line[j]
			@locals << []
			#verifica cada caracter separadamente e atribui os blocos
			for i in (0..line[0].size- 1)
				
	  			character = each_line.slice(i, 1) 
	  			case character
	  			when 'm'
	  				#@locals[[j,i]] = "metal"
	  				@locals[j][i] = Block.new(i*64,j*64,"map1",:wall,2)
	  			when '.'
	  				#@locals[[j,i]] = "caminho"
	  				@locals[j][i] = Block.new(i*64,j*64,"map1",:empty,2)
	  			when 's'
	  				#@locals[[j,i]] = "ese"
	  				@locals[j][i] = Block.new(i*64,j*64,"map1",:empty,2)
	  			else
	  				
	  			end
			end
		end
		#puts @locals
	end

	def update_blocks file_server

	end

	#recebe as posicões x e y em pixels
	def can_move_to posX, posY
		posBlockX = (posX/BLOCK_DIM.to_f).ceil-1
		posBlockY = (posY/BLOCK_DIM.to_f).ceil-1		
		@locals[posBlockX][posBlockY].get_type == :empty || @locals[posBlockX][posBlockY].get_type == :buff	
	end

	def block_now

	end

   	def draw
     	#@background_image.draw(0, 0, 0)
		 for j in (0..@locals.length-1)
		 	for i in (0..@locals[0].length-1)
		    	@locals[j][i].draw
		  	end
		 end
   	end
end


map = ARGV[0]
Map.new(map).show if __FILE__== $0
