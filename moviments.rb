# Encoding: UTF-8

require 'rubygems'
require 'gosu'

WIDTH, HEIGHT = 800, 600

class GameWindow < Gosu::Window 
  def initialize
    super WIDTH, HEIGHT
    
    self.caption = "Gosu Game"
    
    @background_image = Gosu::Image.new("assets/images/aula/space.bmp", :tileable => true)
    @sprite = Gosu::Image.load_tiles self, "assets/images/personagem/completo.png", 250, 509, true
    @frame = 0
    
    # posicao quando parado no sentido em que está. Inicial é parado de frente.
    @stopped = 0
    @bomberman = @sprite[@stopped]
    #centralizar a imagem do personagem
    @x = WIDTH/2 - (@bomberman.width * 0.1)/2 
    @y = HEIGHT/2 - (@bomberman.height * 0.1)/2.0
  end

  def update
    # @x = WIDTH/2 - (@bomberman.width * 0.1)/2 + Math.sin(Time.now.to_f)*150
    # @y = HEIGHT/2 - (@bomberman.height* 0.1)/2 + Math.cos(Time.now.to_f)*200
    @bomberman = @sprite[@stopped]
    @frame += 1 
    @speed = 3
    @x %= WIDTH
    @y %= HEIGHT
    move
  end

  def move
    walk_up if Gosu::button_down? Gosu::KbUp
    walk_down if Gosu::button_down? Gosu::KbDown
    walk_left if Gosu::button_down? Gosu::KbLeft
    walk_right if Gosu::button_down? Gosu::KbRight 
  end

  def walk_left
    @x -= @speed
    #@stopped= 3
    f = 3 + (@frame % @sprite.size/4)
    set_sprite(f, 3)
    #@bomberman = @sprite[f]
  end

  def walk_right
    @x += @speed
    #@stopped = 6
    f = 7 + @frame % @sprite.size/4 -1
    set_sprite(f, 6)
    #@bomberman = @sprite[f]
  end

  def walk_up
    @y -= @speed
    #@stopped = 9
    f = 10 + @frame % @sprite.size/4 -1
    set_sprite(f, 9)
    #@bomberman = @sprite[f]
  end

  def walk_down
    @y += @speed
    #@stopped = 0
    f = 1 + @frame % @sprite.size/4 -1
    set_sprite(f, 0)
    #@bomberman = @sprite[f]
  end

  def set_sprite(f, stopped)
    @stopped = stopped
    @bomberman = @sprite[f]
  end

  def draw
    @background_image.draw 0, 0, 0
    @bomberman.draw(@x, @y, 1, 0.3, 0.3, Gosu::Color.argb(0xff00ff00))
    # @current_nave.draw_rot(@x, @y, 1, 0.1, 30*0.1)
  end

  def button_down(id)
    if id == Gosu::KbEscape
      close
    end
  end
end

GameWindow.new.show if __FILE__ == $0

