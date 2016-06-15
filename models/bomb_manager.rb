# Encoding: UTF-8
require_relative "bomb"
class BombManager
	attr_accessor :planted_bombs
	def initialize player
		@player = player
		@range
		@planted_bombs_quantity # => Quantidade de bombas plantadas
		@planted_bomb_limit	# => Quantidade de bombas limite
		@explosion_range # => Quantidade em blocos do range da explosao
		@planted_bombs = Array.new
	end

	def planted_bombs_quantity
		@planted_bombs_quantity
	end

	def planted_bombs_limit action=''
		@planted_bomb_limit += 1 if action == :increment
		@planted_bomb_limit -= 1 if action == :decrement
		@planted_bomb_limit unless action
	end

	def plant_bomb
		# => Adicionar no array de bombas
		@planted_bombs << Bomb.new(@player)
		Thread.start {
			sleep 5
			p "explodiu"
			@planted_bombs.shift
		}
		# => Criar thread para contagem regressiva
		# => Explodir 

	end

	def range action=:increment
		@explosion_range += 1 if action == :increment
		@explosion_range -= 1 if action == :decrement
		@explosion_range unless action
	end
end