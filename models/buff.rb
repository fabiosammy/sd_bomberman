# BUFF Types
# => :immortal
# => :kick_wall
# => :rollerblades
# => :death
# => :kick_bomb
# => :increase_explosion
# => :increase_amount_bomb

class Buff
  attr_reader :timer
  attr_reader :image

  def initialize buff_type
    @buff_type = buff_type
    @timer = 0
    @image = Gosu::Image.new "assets/images/buffs/buff_#{buff_type.to_s}.bmp"
  end

  def attrib_player player
    @player = player
  end

  def apply_buff
    self.method(@buff_type.to_s).call :configure
    self.method(@buff_type.to_s).call :apply
  end

  #Removera o respectivo atributo dado ao player
  def remove_attribute
    self.method(@buff_type.to_s).call :remove
  end

  def immortal action = :apply
    if action == :configure then
      @timer = 8

    elsif action == :apply then
      @player.set_immortal=true

    elsif action == :remove then
      @player.set_immortal=false

    end

  end

  def kick_wall action = :apply
    if action == :configure then
      @timer = 20

    elsif action == :apply then
      @player.allow_kick_wall true

    elsif action == :remove then
      @player.allow_kick_wall false

    end
  end

  def rollerblades action = :apply
    if action == :configure then
      @timer = 5

    elsif action == :apply then
      @player.set_velocity :increment

    elsif action == :remove then
      @player.set_velocity :decrement

    end
  end

  def death action = :apply
    if action == :configure then
      @timer = 0

    elsif action == :apply then
      @player.die

    end
  end

  def kick_bomb action = :apply
    if action == :configure then
      @timer = 0

    elsif action == :apply then
      @player.allow_kick_bomb

    end
  end

  def increase_explosion action = :apply
    if action == :configure then
      @timer = 0

    elsif action == :apply then
      @player.bomb_explosion_range :increment

    end
  end

  def increase_amount_bomb action = :apply
    if action == :configure then
      @timer = 0

    elsif action == :apply then
      @player.planted_bombs_limit :increment

    end
  end


end