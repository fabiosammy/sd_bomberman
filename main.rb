# Encoding: UTF-8

require 'rubygems'
require 'gosu'
require 'celluloid/current'
require 'celluloid/io'
require 'socket'
require 'securerandom'

require_relative 'models/bomberman'

WIDTH, HEIGHT = 800, 600

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
    super WIDTH, HEIGHT
    
    @client = Client.new(server, port)
    self.caption = "Bomberman Game"

    # Mapa
    @map = Gosu::Image.new "assets/images/cenarios/map2.bmp", :tileable => true

    # Bomberman
    @player = Bomberman.new(self)
    @bombs = Array.new

    @player.stay(320, 240)
    # @player.velocity = 3
    
    # Posição inicial do bomberman a partir da sprite.
    @frame = 0


    # Variáveis para troca de informações
    @another_bombermans = Hash.new # Demais jogadores
    @messages = Array.new # Fila para troca de mensagens

    #add_to_message_queue('player', @player.to_socket_send)
  end

  # Game handle connections
  # add a message to the queue to send to the server
  def add_to_message_queue(msg_type, socket_send_message)
    #message = ["#{msg_type}|#{socket_send_message}|\n"] # Cria o array de mensagens
    # Verifica todos os objetos em comum e partilha entre os jogadores
    # [:uuid, :x, :y, :direction].each do |instance|
    #    # Pega cada instancia do objeto e adiciona na mensagem 
    # end
    @messages.push("#{msg_type}|#{socket_send_message}\n")
    p "CLIENT: Added to queue #{@messages}"
  end

  # Game methods
  def update
    @frame += 1
    @frame = @frame % 3

    @player.stopped
    
    button_listener
    queue_execute
  end

  def send_queue
    p @messages
    @messages.each do |message|
      @client.send_message message
    end
    p "CLIENT: Queue sended"
    @messages.clear
    p "CLIENT: Queue cleared"
  end

  def read_socket
    message = @client.read_message.split('|')
    p "CLIENT: Readed from socket #{message}"
    self.method("socket_method_"+message[0]).call message

  end

  def socket_method_player message
    p "CLIENT: Message in player method #{message}"
    #@another_bombermans.add(Bomberman.new(self, socket_data[1], socket_data[2], socket_data[3],socket_data[4]))
  end

  def queue_execute
    add_to_message_queue('player', @player.to_socket_send)
    send_queue
    read_socket
    # # Envia para o socket as mensagens coletadas do jogador

    # # Faz a leitura de mensagens do servidor
    # if msg = @client.read_message
    #   data = msg.split("&")
    #   # verifica os objetos escritos em "arena.rb"
    #   data.each do |row|
    #     attributes = row.split("|")
    #     if attributes.size == 5
    #       uuid = attributes[1]
    #       unless @uuid == uuid # Garante que o objeto não seja o proprio jogador
    #         # Instancia o novo bomberman da rede localmente
    #         if attributes[0] == 'player'
    #           @another_bombermans[uuid] = Bomberman.from_sprite(self, attributes)              
    #         end
    #       end
    #     end
    #   end
    # end
  end

  def button_listener
    if Gosu::button_down? Gosu::KbSpace
      @player.plant_bomb
    end 
    if Gosu::button_down? Gosu::KbUp
      @player.move(@frame, :up)
    elsif Gosu::button_down? Gosu::KbDown
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

    bombs.each { |bomb| bomb.draw }
    @map.draw 0, 0, 0
    @another_bombermans.each_value {|bomberman| bomberman.draw}
    @player.draw
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
