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
    @player.stay(320, 240)

    @bombs = Array.new

    # @player.velocity = 3
    
    # Posição inicial do bomberman a partir da sprite.
    @frame = 0

    # Variáveis para troca de informações
    @others_players = Hash.new # Demais jogadores
    @messages = Array.new # Fila para troca de mensagens
    # add_to_message_queue('player', @player.to_socket_send)
  end

  # Game handle connections
  # add a message to the queue to send to the server
  def add_to_message_queue(msg_type, socket_send_message)
    #message = ["#{msg_type}|#{socket_send_message}|\n"] # Cria o array de mensagens
    # Verifica todos os objetos em comum e partilha entre os jogadores
    # [:uuid, :x, :y, :direction].each do |instance|
    #    # Pega cada instancia do objeto e adiciona na mensagem 
    # end
    @messages.push << "#{msg_type}|#{socket_send_message}"
    p "CLIENT: Added to queue: #{@messages}"
  end
 
  # Game methods
  def update
    @player.stopped
    stopped_others
    
    button_listener

    queue_execute
    render_others_players
  end

  def send_queue
    # Envia para o socket as mensagens coletadas do jogador
    @messages.each do |message|
      p "This message from client to socket: #{message}"      
      @client.send_message "#{message}\n"
    end
    @messages.clear
    p "CLIENT: Queue cleared"
  end

  def read_socket  
    # Faz a leitura de mensagens do servidor
    if msg = @client.read_message
      # p "Message give to socket: #{msg}"
      array_data = msg.split("\n")
      # p "READED from socket #{array_data}"       
      array_data.each do |row|
        attributes = row.split("|")
        # p "READED: Attributos--- #{attributes}"
        self.method("socket_method_"+attributes[0]).call attributes
      end
    end
  end

  def socket_method_player socket_data
    p "CLIENT: Message in player method #{socket_data[1]}"
    uuid = socket_data[1]
    unless @uuid == uuid
      @others_players[uuid] = (Bomberman.new(self, socket_data[1], socket_data[2], socket_data[3], socket_data[4], socket_data[5]))
      p "Bomberman criado: #{@others_players[uuid].x}"
    end
  end

  def queue_execute
    add_to_message_queue('player', @player.to_socket_send)

    send_queue
    read_socket
  end

  def increment_frame
    @frame += 1
    @frame = @frame % 3
  end

  def button_listener
    if Gosu::button_down? Gosu::KbSpace
      @player.plant_bomb
    end 
    if Gosu::button_down? Gosu::KbUp
      increment_frame
      @player.move(@frame, :up)
    elsif Gosu::button_down? Gosu::KbDown
      increment_frame
      @player.move(@frame, :down)
    elsif Gosu::button_down? Gosu::KbLeft
      increment_frame
      @player.move(@frame, :left)
    elsif Gosu::button_down? Gosu::KbRight
      increment_frame
      @player.move(@frame, :right)
    end
  end

  def stopped_others
    @others_players.each_value do |player|
      player.stopped
    end
  end

  def render_others_players
    @others_players.each_value do |player|
      frame = player.frame.gsub(/[^\d\.]/, '').to_i
      player.move(frame, player.direction)
    end
  end

  def draw
    @player.draw
    bombs = @player.bomb_manager.planted_bombs

    bombs.each { |bomb| bomb.draw }
    @map.draw 0, 0, 0
    @others_players.each_value { |bomberman| bomberman.draw }
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
