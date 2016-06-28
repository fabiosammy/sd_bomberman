#Encoding UTF-8
class Bomb

	def initialize player
		@x,	@y = player.x, player.y

		@image = Gosu::Image.new player.window, "assets/images/bomba/bombas_1.png"
		@sprite = Gosu::Image.load_tiles(player.window, "assets/images/bomba/bombas_1.png", @image.width/4, @image.height, true)
		@image_slice = @sprite[0]
		# => Desenhar bomba na tela em x,y


	end

	# => Efeito para mover (chutar) a bomba no mapa
	def moveTo x, y

	end



	def explode range
		@image_slice = @sprite[1]
		sleep 0.1
		@image_slice = @sprite[2]
		sleep 0.1
		@image_slice = @sprite[3]
		p "explodiu"
		
	end

	def draw
		@image_slice.draw(@x, @y, 2)
	end
end