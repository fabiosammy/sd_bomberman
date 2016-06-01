# Encoding: UTF-8
class BombManager
	def initialize player
		@player = player
		@range
		@planted_bombs_quantity # => Quantidade de bombas plantadas
		@planted_bomb_limit	# => Quantidade de bombas limite
		@explosion_range # => Quantidade em blocos do range da explosao
	end

	def plantedBombsQuantity
		@planted_bombs_quantity
	end

	def plantedBombsLimit action=''
		@planted_bomb_limit ++ if action == :increment
		@planted_bomb_limit -- if action == :decrement
		@planted_bomb_limit unless action
	end

	def plantBomb
		# => Adicionar no array de bombas
		bomb = Bomb.new(player)

		# => Criar thread para contagem regressiva
		# => Explodir 

	end

	def range action=:increment
		@explosion_range ++ if action == :increment
		@explosion_range -- if action == :decrement
		@explosion_range unless action
	end
end