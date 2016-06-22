#Encoding UTF-8
class Bomb

	def initialize player
		@x,	@y = player.x, player.y
		@image = Gosu::Image.new player.window, "assets/images/obstaculos/block_destroyable2_gray.png"
		# => Desenhar bomba na tela em x,y


	end

	# => Efeito para mover (chutar) a bomba no mapa
	def moveTo x, y

	end



	def explode range
		p "explodiu"
		#Efeito de explodir
		#atingir elementos no mapa
		#apagar da memoria
	end

	def draw
		@image.draw(@x, @y, 2)
	end
end