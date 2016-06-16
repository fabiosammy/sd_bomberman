# Encoding: UTF-8

require 'rubygems'
require_relative 'bomb_manager'
require_relative 'buff'

class Bomberman
  attr_accessor :velocity
  attr_reader :x
  attr_reader :y
  attr_accessor :window
  attr_reader :bomb_manager

  def initialize(window)
    # carrega sprite do bomberman e as transforma em uma array de imagens.
    @sprite = Gosu::Image.load_tiles(window, "assets/images/personagem/sprite.png", 246, 506, true)
    
    @window = window

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

  def plant_bomb
    @bomb_manager.plant_bomb
  end

  #
  # => Funçao para atribuir um Buff ao personagem
  #
  def give_buff(buff_type = :no_buff)
    #criar thread para verificar condiçao dos buffs
    buff = Buff.new(buff_type)
    attrib_buff buff
  end

  def attrib_buff buff
    buff.attrib_player self
    buff.apply_buff

    if buff.timer != 0 then
      Thread.start {
        sleep buff.timer
        buff.remove_attribute
      }
    end

  end

  # => Mata ele
  def die()
    # => Animacao dele morrendo
    # => bloqueia movimento
    # => Altera imagem
  end

  #
  # => BUFFs
  #

  #Controle da imortalidade do personagem
  def set_immortal(action=false)
    @player.immortal = action
  end

  #Aumenta ou diminui a quantidade maxima de bombas plantadas simultaneamente
  def planted_bombs_limit(action=:increment)
    @bomb_manager.planted_bombs_limit action
  end

  #Aumenta ou diminui o range da explosao
  def bomb_explosion_range(action=:increment)
    @bomb_manager.explosion_range action
  end

  #Aumenta ou diminui a velocidade do jogador
  def set_velocity action=:increment
    if action == :increment and @velocity <= 3
      @velocity += 1

    elsif action == :decrement and @velocity > 1
      @velocity -= 1

    end
  end

  # => Permite o jogador chutar bombas
  def allow_kick_bomb
    @kick_bomb = true
  end

  # => Chuta uma bomba
  def kick_bomb(bomb)
    bomb_manager.getBomb(bomb).moveTo(@new_x, @new_y)
    #or bomb.moveTo(:direction)
  end

  # => Chuta uma parede
  def kick_wall(wall)
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

