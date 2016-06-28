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
    @player = Bomberman.new(self, uuid)
    p "Uiid player [#{@player.uuid}]"
    @player.stay(320, 240)

    @bombs = Array.new

    @method = "stopped"

    # @player.velocity = 3
    
    # Posição inicial do bomberman a partir da sprite.
    @frame = 0

    # Variáveis para troca de informações
    @others_players = Hash.new # Demais jogadores
    @others_bombs = Array.new # Demais bombas
    @messages = Array.new # Fila para troca de mensagens
  end
 
  # Game methods
  def update
    @frame += 1
    @frame %= 3

    @player.stopped
    stopped_others
    
    button_listener

    queue_execute

    render_others_players
  end

  def queue_execute
    add_to_message_queue('player', @player.to_socket_send)

    @bombs.each do |bomb|
      add_to_message_queue('bomb', bomb.to_socket_send)
    end

    send_queue
    read_socket
  end

  # Game handle connections
  # add a message to the queue to send to the server
  def add_to_message_queue(msg_type, socket_send_message)
    #message = ["#{msg_type}|#{socket_send_message}|\n"] # Cria o array de mensagens
    # Verifica todos os objetos em comum e partilha entre os jogadores
    # [:uuid, :x, :y, :direction].each do |instance|
    #    # Pega cada instancia do objeto e adiciona na mensagem 
    # end
    @messages.push << "#{msg_type}|#{socket_send_message}|#{@method}"
     p " Messages Push --> #{msg_type}|#{socket_send_message}|#{@method}"
     @method = "stopped"
   
  end

  def send_queue
    # Envia para o socket as mensagens coletadas do jogador
    @messages.each do |message|
      # p "This message from client to socket: #{message}"    
      @client.send_message "#{message}\n"
    end
    @messages.clear    

  end

  def read_socket  
    # Faz a leitura de mensagens do servidor
    if msg = @client.read_message

      array_data = msg.split("\n")
      p "Message give to socket: #{array_data.size}"

      # p "READED from socket #{array_data}"       
      array_data.each do |row|
        # p "Cada Objeto +++=== > #{row}"
        attributes = row.split("|")
        # p "READED: Attributos--- #{attributes}"
        self.method("socket_method_"+attributes[0]).call attributes
        # execute_methods
      end
    end
  end

  # def execute_methods
  #   @others_players.each do |player|
  #     player.self.method("#{player.method}").call
  #   end
  # end

  def socket_method_player socket_data
    uuid = socket_data[1]

    unless @player.uuid == uuid
      @others_players[uuid] = (Bomberman.new(self, socket_data[1], socket_data[2], socket_data[3], socket_data[4], socket_data[5]))
      @others_players[uuid].method("#{socket_data[6]}").call
      p "chmando meodo #{socket_data[6]} de #{@others_players[uuid]}"

    end
  end

  def button_listener
    if Gosu::button_down? Gosu::KbSpace
      @player.plant_bomb
      @method = 'plant_bomb'
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

    # Dispara a bomba dos jogadores da rede
    @others_players.each_value do |bomberman| 
      bomberman.draw
      bomb_player = bomberman.bomb_manager.planted_bombs
      bomb_player.each { |bomb| bomb.draw }
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
