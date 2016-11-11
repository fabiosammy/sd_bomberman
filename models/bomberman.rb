# Encoding: UTF-8

require 'rubygems'
require_relative 'bomb_manager'
require_relative 'buff'

class Bomberman
  attr_accessor :window, :frame, :direction
  attr_reader :uuid, :x, :y, :bomb_manager

  # metodo para criar um novo objeto da rede
  def self.from_sprite(window, socket_data)
    Bomberman.new(window, socket_data[1], socket_data[2], socket_data[3], socket_data[4], socket_data[5], socket_data[6])
  end

  def initialize (window, uuid = SecureRandom.uuid, x = 0, y = 0, direction = :up, frame = 0, method = '')
    @window = window
    @sprite = Gosu::Image.load_tiles(window, "assets/images/personagem/completo100.png", 50, 100, true)
    @uuid = uuid
    @method = method
    @x = x.to_f
    @y = y.to_f
    @direction = direction
    @frame = 0

    # posicao do bomberman parado no sentido em que está. Inicial é parado de frente.
    @stopped = 0
    @image = @sprite[@stopped]

    @bomb_manager = BombManager.new self
    @buffs = []
    @method = 'die'

    @velocity = 2

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

  def plant_bomb
    @method = 'plant_bomb'
    @bomb_manager.plant_bomb
  end

  # 
  # => MOVIMENTAÇAO
  #
  def move(direction = :up)
    @direction = direction
    # Somente para armazenar na variavel frame, para depois acessar externamente a imagem correta nos outros clientes.
    @frame += 1
    @frame = @frame%3
    @method = "walk_#{direction.to_s}"
    self.method("walk_"+@direction.to_s).call
  end

  def walk_left
    @x -= @velocity
    @stopped = 4
    f = 4 + @frame
    @image = @sprite[f]
  end

  def walk_right
    @x += @velocity
    @stopped = 2
    f = @frame
    @image = @sprite[f]
  end

  def walk_up
    @y -= @velocity
    @stopped = 10
    f = 9 + @frame
    @image = @sprite[f]
  end

  def walk_down
    @y += @velocity
    @stopped = 3
    f = 7 + @frame
    @image = @sprite[f]
  end

  #
  # => Funçao para atribuir um Buff ao personagemuuid = message[1]
    # method = message[4]
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
  def set_immortal(action = false)
    @player.immortal = action
  end

  #Aumenta ou diminui a quantidade maxima de bombauuid = message[1]
    # method = message[4]s plantadas simultaneamente
  def planted_bombs_limit(action = :increment)
    @bomb_manager.planted_bombs_limit action
  end

  #Aumenta ou diminui o range da explosao
  def bomb_explosion_range(action = :increment)
    @bomb_manager.explosion_range action
  end

  #Aumenta ou diminui a velocidade do jogador
  def set_velocity action = :increment
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
  
  def stopped
    #@method = 'stopped'
    @image = @sprite[@stopped]
  end

  def draw
    # @image.draw(@x, @y, 1, 0.34, 0.2)
    @image.draw(@x, @y, 1, 0.84, 0.62)
  end

  def to_socket_send
    "#{@uuid}|#{@x}|#{@y}|#{@direction}|#{@method}"
  end
end

