# Encoding: UTF-8
require 'rubygems'
require 'gosu'

#WIDTH, HEIGHT = 1750, 900
BLOCK_DIM = 64

class Map < Gosu::Window
	
	#file = File.open("assets/images/cenarios/map1")
	#background_image = Gosu::Image.new("assets/images/cenarios/map3.bmp", :tileable => true)
	@file
	@width
	@height

	def initialize #file, background_image	
		# pegar o arquivo, criar uma array de acordo com o arquivo	
		@file = File.open("assets/images/cenarios/map1") #unless file
		window = File.open("assets/images/cenarios/map1")
		@locals = Hash.new
		@block = Gosu::Image.new("assets/images/cenarios/bricks1.png")
		@background_image = Gosu::Image.new("assets/images/cenarios/map0.bmp", :tileable => true) #unless background_image
	
		
		set_window_size window
		#metodo para identificar os caracteres do file
		generateBlocks @file
		
		super @width-BLOCK_DIM, @height
    	#@client = Client.new(server, port)
    	self.caption = "BomberMANO"
    	
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
			
			#verifica cada caracter separadamente e atribui os blocos
			for i in (0..line[0].size- 1)
				
	  			character = each_line.slice(i, 1) 
	  			case character
	  			when 'm'
	  				@locals[[j,i]] = "metal"
	  				#@locals[[j,i]] = Block.new(:fixed)
	  			when '.'
	  				@locals[[j,i]] = "caminho"
	  				#@locals[[j,i]] = Block.new(:empty)
	  			when 's'
	  				@locals[[j,i]] = "ese"
	  				#@locals[[j,i]] = Block.new(:empty)
	  			else
	  				
	  			end
			end
		end
		#puts @locals
	end

	def update_blocks file_server

	end

	def can_move_to posX, posY
		
	end

	def block_now

	end

   	def draw
  		
     	#@background_image.draw(0, 0, 0)
	     line = @locals.length

		 h = 0
	     k = 0
		 for j in (0..line- 1)
		 	j = j*BLOCK_DIM
		 	for i in (0..line)
		 	 	i = i*BLOCK_DIM
		 	 	if(@locals[[h,k]] == "metal")
		    			@block.draw(i,j,0)
		    		end	
		    		k += 1
		  	end
		  	h += 1
		  	k = 0
		  end
   	end
end


Map.new.show if __FILE__== $0