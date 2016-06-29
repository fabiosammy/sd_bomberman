# Encoding: UTF-8

require 'rubygems'
require 'gosu'
require 'celluloid/current'
require 'celluloid/io'
require 'socket'
require 'securerandom'

require_relative 'models/bomberman'
require_relative 'models/map'



class Client
  include Celluloid::IO

  def initialize(server, port)
    begin
      @socket = TCPSocket.new(server, port)
    rescue
      $error_message = "Cannot find game server."
    end
  end

  def send_message(message)
    @socket.write(message) if @socket
  end

  def read_message
    @socket.readpartial(4096) if @socket
  end
end

class GameWindow < Gosu::Window
  def initialize(server, port, uuid)
    # Mapa
    @map = Map.new("map2")
    super @map.get_width, @map.get_heigth
    
    @client = Client.new(server, port)
    self.caption = "Bomberman Game"

    
    

    # Bomberman
    @player = Bomberman.new(self,SecureRandom.uuid, 65,65)

    @player.stay(320, 240)
    # @player.velocity = 3
    
    # Imagem inicial do bomberman a partir da sprite.
    @frame = 0

    # Variáveis para troca de informações
    @another_bombermans = Hash.new # Demais jogadores
    @messages = Array.new # Fila para troca de mensagens

    add_to_message_queue('player', @player)
  end

  # Game handle connections
  # add a message to the queue to send to the server
  def add_to_message_queue(msg_type, object)
    message = [msg_type] # Cria o array de mensagens
    # Verifica todos os objetos em comum e partilha entre os jogadores
    [:uuid, :x, :y].each do |instance|
       # Pega cada instancia do objeto e adiciona na mensagem 
       message.push(object.instance_variable_get("@#{instance}"))
    end
    @messages << message.join('|')
  end

  # Game methods
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
      if @map.can_move_to @player.x, @player.y-1
        @player.move(@frame, :up)
      end
    elsif  Gosu::button_down? Gosu::KbDown
      if @map.can_move_to @player.x, @player.y+1
        @player.move(@frame, :down)
      end
    elsif Gosu::button_down? Gosu::KbLeft
      if @map.can_move_to @player.x-1, @player.y
        @player.move(@frame, :left)
      end
    elsif Gosu::button_down? Gosu::KbRight
      if @map.can_move_to @player.x+1, @player.y
      @player.move(@frame, :right)
      end
    end

  end

  def draw
    @player.draw
    bombs = @player.bomb_manager.planted_bombs

    bombs.each { |bomb| bomb.draw }
    @map.draw
    @another_bombermans.each_value {|bomberman| bomberman.draw}
    @player.draw
  end

  def queue_execute
    add_to_message_queue('player', @player)

    # # Envia para o socket as mensagens coletadas do jogador
    @client.send_message @messages.join("\n")
    @messages.clear

    # # Faz a leitura de mensagens do servidor
    if msg = @client.read_message
      data = msg.split("\n")
      # verifica os objetos escritos em "arena.rb"
      data.each do |row|
        attributes = row.split("|")
        if attributes.size == 4
          uuid = attributes[1]
          unless @uuid == uuid # Garante que o objeto não seja o proprio jogador
            # Instancia o novo bomberman da rede localmente
            if attributes[0] == 'player'
              @another_bombermans[uuid] = Bomberman.from_sprite(self, attributes)
            end
          end
        end
      end
    end
  end

  def button_down(id)
    if id == Gosu::KbEscape
      close
    end
  end
end

# A variavel NAVESHIP_ARENA_PORT_5532_TCP_ADDR vem do link do docker, que pode ser visto com bin/docker_run
server, port = ARGV[0] || ENV['SD_BOMBERMAN_ARENA_PORT_5532_TCP_ADDR'], ARGV[1] || 5532
GameWindow.new(server, port, SecureRandom.uuid).show if __FILE__ == $0
