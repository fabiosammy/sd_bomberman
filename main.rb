# Encoding: UTF-8

require 'rubygems'
require 'gosu'
require_relative 'models/bomberman'

WIDTH, HEIGHT = 800, 600

class GameWindow < Gosu::Window
  def initialize
    super WIDTH, HEIGHT

    self.caption = "Bomberman Game"

    @map = Gosu::Image.new "assets/images/cenarios/map2.bmp", :tileable => true

    @player = Bomberman.new(self)
    @player.warp(320, 240)
    @player.velocity = 3
    @frame = 0
  end

  def update
    @frame += 1 
    @player.stopped
    
    @player.move(@frame, :up) if Gosu::button_down? Gosu::KbUp
    @player.move(@frame, :down) if Gosu::button_down? Gosu::KbDown
    @player.move(@frame, :left) if Gosu::button_down? Gosu::KbLeft
    @player.move(@frame, :right) if Gosu::button_down? Gosu::KbRight 
  end

  def draw
    @player.draw
    @map.draw 0, 0, 0
  end

  def button_down(id)
    if id == Gosu::KbEscape
      close
    end
  end
end

GameWindow.new.show if __FILE__ == $0

