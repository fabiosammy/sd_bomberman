# Encoding: UTF-8
require_relative "bomb"
class BombManager
	DELAY_TO_EXPLODE = 3
	attr_accessor :planted_bombs

	def initialize player
		@player = player
		@range = 2
		@planted_bombs_quantity = 0# => Quantidade de bombas plantadas
		@planted_bombs_limit = 1	# => Quantidade de bombas limite
		@explosion_range # => Quantidade em blocos do range da explosao
		@can_plant = true
		@planted_bombs = Array.new
	end

	def planted_bombs_quantity
		@planted_bombs_quantity
	end

	def planted_bombs_limit action=''
		@planted_bombs_limit += 1 if action == :increment
		@planted_bombs_limit -= 1 if action == :decrement
		@planted_bombs_limit unless action
	end

	def plant_bomb
		if (@planted_bombs_quantity < @planted_bombs_limit && @can_plant == true)
			# => Bloqueia de plantar mais bombas
			@can_plant = false
			bomb = Bomb.new(@player)

			# => Adicionar no array de bombas
			@planted_bombs << bomb
			@planted_bombs_quantity += 1

			# => Thread para liberar plantar mais bombas
			Thread.start {
				sleep 1
				@can_plant = true
			}

			# => Thread para explodir a bomba
			Thread.start {
				sleep DELAY_TO_EXPLODE
				bomb.explode @range
				@planted_bombs.shift
				@planted_bombs_quantity -= 1
			}
		end
		# => Criar thread para contagem regressiva
		# => Explodir 

	end

	def range action=:increment
		@explosion_range += 1 if action == :increment
		@explosion_range -= 1 if action == :decrement
		@explosion_range unless action
	end
end