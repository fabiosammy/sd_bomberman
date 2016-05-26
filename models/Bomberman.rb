# Encoding: UTF-8

require 'rubygems'

class Bomberman
  attr_acessor: immortal
  attr_acessor: kick_wall
  attr_acessor: kick_bomb

  x = 0
  y = 0

  bomb_manager
  buffs = []

  velocity=1

  #Define imortalidade do personagem
  immortal=false

  #Permite ou nao o personagem chutar paredes
  kick_wall=false

  #Permite ou nao o personagem chutar bombas
  kick_bomb=false


  def initialize
    bomb_manager = BombManager.new(self);
  end

  #Funçao para atribuir um Buff ao personagem
  #
  #
  def giveBuff(buff_type=:no_buff)
    #criar thread para verificar condiçao dos buffs
    timer, buff = buff.new(buff_type, self)

    @buffs.push buff_add

    if buff.timer != 0
      #thread para:
      # sleep buff.timer
      # buff.removeAttribute()
    end
    
    @buffs.pop buff

  end

  def move(direction=:up)
    :up
    :left
    :down
    :rigth
  end
  
  def plantBomb()
      bomb_manager.plantNew(self)
  end

  def die()

  end

  #Aumenta ou diminui a quantidade maxima de bombas plantadas simultaneamente
  def plantedBombLimit(action=:increment)
    # :decrement
  end

  #Aumenta ou diminui o range da explosao
  def bombExplosionRange()
    # :decrement
    bomb_manager.range(:increment)
  end

  #Aumenta ou diminui a velocidade do jogador
  def playerVelocity(action=:increment)
    # :decrement
  end


  def kickBomb(bomb)
    bomb_manager.getBomb(bomb).moveTo(@new_x, @new_y)
    #or bomb.moveTo(:direction)
  end

  def kickWall(wall)
    wall.moveTo(@new_x, @new_y)
    #or wall.moveTo(:direction)
  end
end

