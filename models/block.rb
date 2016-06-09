# => :empty
# => :wall
# => :wall_buff
# => :fixed
# => :buff

# Encoding: UTF-8
require 'gosu'
require 'rubygems'
require_relative 'buff'


class Block
  
  @type
  @image
  @buff
  @buff_type
  @x
  @y
  @h
  @map_name
  @angle
  
    
    def initialize (x = 0, y = 0, map_name = "", type = :empty)
      
      @h = Hash.new
      @h[:empty] = "assets/images/obstaculos/block_empty.png"
      @h[:wall_buff] = "assets/images/obstaculos/block_wall_#{map_name}.png"
      @h[:wall] = "assets/images/obstaculos/block_wall_#{map_name}.png"
      @h[:fixed] = "assets/images/obstaculos/block_fixed_#{map_name}.png"
      @x = x
      @y = y
      @type = type
      @map_name = map_name
      @angle = 0
      @buff_type = :immortal
      set_buff_type(Random.rand 2)

      update_image(@type)
      
    end
    def set_buff_type(rand)
      case rand
        when 0
            @buff_type = :immortal
        when 1
            @buff_type = :death
        else 
            @buff_type = :flame
        end
    end
    def get_type()
      @type
    end

    def get_buff()
      @buff
    end

    def update_image(type)
      if @type != :buff && @type != :empty
        @image = Gosu::Image.new @h[type], :tileable => true
      end
    end

    def destroy()
        case @type
        when :wall
            @type = :empty
        when :wall_buff
            @type = :buff
            @buff = Buff.new(@buff_type)
            @image = @buff.image
        when :buff
            @type = :empty
        end
        update_image(@type)
        
    end

    def draw
        @image.draw_rot(@x, @y, 99, @angle)
    end

end
