# Encoding: UTF-8
class Map
	@file
	@locals
	@background
	
	def initialize file background
		# pegar o arquivo, criar uma array de acordo com o arquivo
		# atribuir blocos fixos na array
	end

	def generateBlocks
		# gerar paredes que podem ser explodidas
	end

	#retorna se o personagem pode ou nao se mover para o bloco X Y
	def getBlockType posX posY
		# true: lugar vazio ou com bloco de buff
		# false: demais ocasioes
	end

	end
end
