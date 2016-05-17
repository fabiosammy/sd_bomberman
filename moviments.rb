# Encoding: UTF-8

require 'rubygems'
require 'gosu'

WIDTH, HEIGHT = 800, 600

class GameWindow < Gosu::Window
  def initialize
    super WIDTH, HEIGHT
    
    self.caption = "Gosu Game"
    
    @background_image = Gosu::Image.new("assets/images/aula/space.bmp", :tileable => true)
    @left = Gosu::Image.load_tiles self, "assets/images/aula/left.png", 576, 358, true
    @down = Gosu::Image.load_tiles self, "assets/images/aula/down.png", 358, 576, true
    @current_nave = @down[4]

    @f = @frame = 0

    @x = WIDTH/2 - (@current_nave.width * 0.1)/2 
    @y = HEIGHT/2 - (@current_nave.height* 0.1)/2
  end

  def update
    # @x = WIDTH/2 - (@current_nave.width * 0.1)/2 + Math.sin(Time.now.to_f)*150
    # @y = HEIGHT/2 - (@current_nave.height* 0.1)/2 + Math.cos(Time.now.to_f)*200
    @frame += 1 
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
    @x -= 5
    @f = @frame % (@left.size/2)
    @current_nave = @left[@f]
  end

  def walk_right
    @x += 5
    @f = 4 + (@frame % (@left.size/2))
    @current_nave = @left[@f]
  end

  def walk_up
    @y -= 5
    @f = 4 + (@frame % (@down.size/2))
    @current_nave = @down[@f]
  end

  def walk_down
    @y += 5
    @f = @frame % (@down.size/2)
    @current_nave = @down[@f]
  end

  def draw
    @background_image.draw 0, 0, 0
    @current_nave.draw(@x, @y, 1, 0.3, 0.3)
    # @current_nave.draw_rot(@x, @y, 1, 0.1, 30*0.1)
  end

  def button_down(id)
    if id == Gosu::KbEscape
      close
    end
  end
end

GameWindow.new.show if __FILE__ == $0

