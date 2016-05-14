# BUFF Types
# => :immortal
# => :kick_wall
# => :rollerblades
# => :death
# => :kick_bomb
# => :increase_explosion
# => :increase_amount_bomb

class Buff
	player
	buff_type

	def initialize buff_type player 
		player = player
		buff_type = buff_type
		timer

		case buff_type
		when :immortal
		  timer = 8
		  @player.immortal=true;

		when :kick_wall
		  timer = 20
		  @player.allowKickWall(true)

		when :rollerblades
		  timer = 30
		  @player.kick_wall=true

		else
		  timer = 0
		end

		[timer, self]
	end

	#Removera o respectivo atributo dado ao player
	def removeAttribute()
		if @buff_type = :immortal
				@player.immortal=false
	end

end