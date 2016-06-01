# BUFF Types
# => :immortal
# => :kick_wall
# => :rollerblades
# => :death
# => :kick_bomb
# => :increase_explosion
# => :increase_amount_bomb

class Buff

  def initialize buff_type player 
    @player = player
    @buff_type = buff_type
    @timer = 0

    self.method(buff_type.to_s).call :configure
    self.method(buff_type.to_s).call :apply

    [@timer, self]
  end

  #Removera o respectivo atributo dado ao player
  def removeAttribute()
    self.method(buff_type.to_s).call :remove

  end

  def immortal action = :apply
    if action == :configure then
      @timer = 8

    elsif action == :apply then
      @player.immortal=true;

    elsif action == :remove then
      @player.immortal=false;

    end

  end

  def kick_wall action = :apply
    if action == :configure then
      @timer = 20

    elsif action == :apply then
      @player.allowKickWall(true)

    elsif action == :remove then
      @player.allowKickWall(false)

    end
  end

  def rollerblades action = :apply
    if action == :configure then
      @timer = 30

    elsif action == :apply then
      @player.velocity(:increment)

    elsif action == :remove then
      @player.velocity(:decrement)

    end
  end

  def death action = :apply
    if action == :configure then
      @timer = 0

    elsif action == :apply then
      @player.die();

    end
  end

  def kick_bomb

  end

  def increase_explosion

  end

  def increase_amount_bomb 

  end


end