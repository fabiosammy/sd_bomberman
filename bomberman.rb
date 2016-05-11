# Encoding: UTF-8

require 'rubygems'

class Bomberman
  @x = 0
  @y = 0

  Bomb bomb

  def initialize
  end

  def giveBuff(buff=:no_buff)

  end

  def move(direction=:up)
    :up
    :left
    :down
    :rigth
  end
  
  def plantBomb()
    bomb.plant(@x,@y)
  end

  def die()
  end

  #Torna o personagem imortal ou nao
  def immortal(status=false)
  end

  #Permite ou nao o personagem chutar bombas
  def allowKickBomb(status=false)
  end

  #Permite ou nao o personagem a chutar paredes
  def allowKickWall(status=false)
  end

  #Aumenta ou diminui a quantidade maxima de bombas plantadas simultaneamente
  def plantedBombLimit(action=:increment)
    # :decrement
  end


  def bombExplosionRange(action=:increment)
    # :decrement
    bomb.range(action)
  end

  def playerVelocity(action=:increment)
    # :decrement
  end



end

