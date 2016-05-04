# Encoding: UTF-8

require 'rubygems'
require 'gosu'

WIDTH, HEIGHT = 600, 600

class GameWindow < Gosu::Window
  def initialize
    super WIDTH, HEIGHT
    
    self.caption = "Gosu Game"
  end

  def update
  end

  def draw
  end
end

GameWindow.new.show if __FILE__ == $0

