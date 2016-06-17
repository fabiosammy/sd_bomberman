# Encoding: UTF-8

require 'rubygems'

class Bomberman
  attr_accessor :immortal
  attr_accessor :kick_wall
  attr_accessor :kick_bomb
  attr_accessor :velocity
  attr_reader :uuid, :x, :y

  # metodo para criar um novo objeto da rede
  def self.from_sprite(window, sprite)
    Bomberman.new(window, sprite[1], sprite[2], sprite[3])
  end

  def initialize (window, uuid = SecureRandom.uuid, x = 0, y = 0)
    @window = window
    @sprite = Gosu::Image.load_tiles(window, "assets/images/personagem/completo100.png", 50, 100, true)
    @uuid = uuid
    @x = x.to_f
    @y = y.to_f

    # posicao do bomberman parado no sentido em que está. Inicial é parado de frente.
    @stopped = 0
    @image = @sprite[@stopped]

    @bomb_manager
    @buffs = []

    self.velocity = 1

    #Define imortalidade do personagem
    @immortal = false

    #Permite ou nao o personagem chutar paredes
    @kick_wall = false

    #Permite ou nao o personagem chutar bombas
    @kick_bomb = false    
  end

  def stay(x, y)
    @x, @y = x, y
  end

  #Funçao para atribuir um Buff ao personagem
  #
  #
  def giveBuff(buff_type = :no_buff)
    #criar thread para verificar condiçao dos buffs
    timer, buff = buff.new(buff_type, self)

    @buffs.push buff_add

    if buff_add.timer != 0
      #thread para:
      # sleep buff.timer
      # buff.removeAttribute()
    end
    
    @buffs.pop buff

  end

  def move(frame, direction = :up)
    walk_up(frame) if direction == :up
    walk_down(frame) if direction == :down
    walk_left(frame) if direction == :left
    walk_right(frame) if direction == :right 
  end
  
  def plantBomb()
    if (bomb_manager.plantedBombs < bomb_manager.plantedBombLimit)
      bomb_manager.plantNew(@x,@y)
    end
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

  def walk_left(frame)
    @x -= velocity
    @stopped = 4
    f = 4 + frame % @sprite.size/4
    @image = @sprite[f]
  end

  def walk_right(frame)
    @x += velocity
    @stopped = 2
    f = frame % @sprite.size/4
    @image = @sprite[f]
  end

  def walk_up(frame)
    @y -= velocity
    @stopped = 10
    f = 9 + frame % @sprite.size/4
    @image = @sprite[f]
  end

  def walk_down(frame)
    @y += velocity
    @stopped = 3
    f = 7 + frame % @sprite.size/4
    @image = @sprite[f]
  end
  
  def stopped
    @image = @sprite[@stopped]
  end

  def draw
    @image.draw(@x, @y, 1, 0.34, 0.2)
  end
end

