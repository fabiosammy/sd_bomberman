# Encoding: UTF-8
class BombManager
	attr_acessor :range

	@range
	@planted_bombs_quantity # => Quantidade de bombas plantadas
	@planted_bomb_limit	# => Quantidade de bombas limite
	@explosion_range # => Quantidade em blocos do range da explosao

	def initialize player
		@player = player
	end


	def plantedBombs

	end

	def plantedBombsQuantity
		@planted_bombs_quantity ++
	end

	def plantedBombsLimit
		@planted_bomb_limit
	end

	def plantBomb player
		# => Adicionar no array de bombas
		bomb = Bomb.new(player)

		# => Criar thread para contagem regressiva
		# => Explodir 

	end

	def moveTo 

	end
end