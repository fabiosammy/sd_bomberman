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
    #@player.velocity = 3
    @frame = 0
  end

  def update
    @frame += 1 
    @player.stopped
    
    button_listener
    queue_execute
  end

  def button_listener
    if Gosu::button_down? Gosu::KbSpace
      @player.plant_bomb
    end 
    if Gosu::button_down? Gosu::KbUp
      @player.move(@frame, :up)
    elsif  Gosu::button_down? Gosu::KbDown
      @player.move(@frame, :down)
    elsif Gosu::button_down? Gosu::KbLeft
      @player.move(@frame, :left)
    elsif Gosu::button_down? Gosu::KbRight
      @player.move(@frame, :right)
    end

  end

  def draw
    @player.draw
    bombs = @player.bomb_manager.planted_bombs
    
    if bombs != nil
      for bomb in bombs
        bomb.draw
      end
    end

    @map.draw 0, 0, 0
  end

  def queue_execute

  end

  def button_down(id)
    if id == Gosu::KbEscape
      close
    end
  end
end

GameWindow.new.show if __FILE__ == $0

