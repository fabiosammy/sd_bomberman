# Encoding: UTF-8

require 'rubygems'

class Bomberman
  attr_accessor :immortal
  attr_accessor :kick_wall
  attr_accessor :kick_bomb
  attr_accessor :velocity

  def initialize(window)
    # carrega sprite do bomberman e as transforma em uma array de imagens.
    @sprite = Gosu::Image.load_tiles(window, "assets/images/personagem/sprite.png", 246, 506, true)
    
    @x = @y = 0
    # posicao do bomberman parado no sentido em que está. Inicial é parado de frente.
    @stopped = 0
    @image = @sprite[@stopped]

    @bomb_manager = BombManager.new self
    @buffs = []

    @velocity = 1

    #Define imortalidade do personagem
    @immortal = false

    #Permite ou nao o personagem chutar paredes
    @kick_wall = false

    #Permite ou nao o personagem chutar bombas
    @kick_bomb = false    
  end

  def warp(x, y)
    @x, @y = x, y
  end

  #Funçao para atribuir um Buff ao personagem
  #
  #
  def giveBuff(buff_type = :no_buff)
    #criar thread para verificar condiçao dos buffs
    timer, buff = buff.new(buff_type, self)

    if timer != 0
      buffThread = Thread.new { 
        sleep timer
        buff.removeAttribute
      }
    end
  end
  
  def plantBomb()
    bomb_manager.plantNew(self)
  end

  def die()

  end

  #Aumenta ou diminui a quantidade maxima de bombas plantadas simultaneamente
  def plantedBombsLimit(action=:increment)
    @bomb_manager.plantedBombsLimit action
  end

  #Aumenta ou diminui o range da explosao
  def bombExplosionRange(action=:increment)
    @bomb_manager.range action
  end

  #Aumenta ou diminui a velocidade do jogador
  def playerVelocity(action=:increment)
    if action == :increment
      @velocity++ if @velocity <= 3
    elseif action == :decrement
      @velocity--;
    end
  end


  def kickBomb(bomb)
    bomb_manager.getBomb(bomb).moveTo(@new_x, @new_y)
    #or bomb.moveTo(:direction)
  end

  def kickWall(wall)
    wall.moveTo(@new_x, @new_y)
    #or wall.moveTo(:direction)
  end


  # 
  # => MOVIMENTAÇAO
  #
  def move(frame, direction = :up)
    self.method("walk_"+direction.to_s).call frame
  end

  def walk_left(frame)
    @x -= velocity
    @stopped = 3
    f = 3 + frame % @sprite.size/4
    @image = @sprite[f]
  end

  def walk_right(frame)
    @x += velocity
    @stopped = 6
    f = 6 + frame % @sprite.size/4
    @image = @sprite[f]
  end

  def walk_up(frame)
    @y -= velocity
    @stopped = 9
    f = 9 + frame % @sprite.size/4
    @image = @sprite[f]
  end

  def walk_down(frame)
    @y += velocity
    @stopped = 0
    f = frame % @sprite.size/4
    @image = @sprite[f]
  end
  
  def stopped
    @image = @sprite[@stopped]
  end

  def draw
    @image.draw(@x, @y, 1, 0.08, 0.06, Gosu::Color.argb(0xff00ff00))
  end
end

