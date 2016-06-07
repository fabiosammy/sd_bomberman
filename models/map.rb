# Encoding: UTF-8
class Map
	@file
	
	#background
	
	def initialize	
		# pegar o arquivo, criar uma array de acordo com o arquivo	
		@file = File.open("map2.txt")
		@locals = Hash.new
		generateBlocks @file
		canMoveTo
	end

	def render

	end

	def generateBlocks file
		#pega todo o arquivo
		line = file.readlines
		for j in (0..line.length- 1)
			#pega apenas a linha 
			each_line = line[j]
			#printa a linha que está selecionada
			#puts each_line
			#verifica cada caracter separadamente e atribui os blocos
			for i in (0..line.length)
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
	end

	def canMoveTo
		for h in (0..@locals.length- 1)
		 	for l in (0..@locals.length) 
	   			case @locals[[h,l]]
	   			when 'metal'
	   				@locals[[h,l]] = "não anda"
	   			when 'caminho'
	   				@locals[[h,l]] = "anda"
	   			when 'ese'
	   				@locals[[h,l]] = "NASCE MANO"
	   			else
	   				
	   			end
		 	end
	 	end
	 p @locals
	end

	#retorna se o personagem pode ou nao se mover para o bloco X Y
	def getBlockType (posX, posY)
		# true: lugar vazio ou com bloco de buff
		# false: demais ocasioes
	end



end


map = Map.new