require 'rubygems'
require 'celluloid/current'
require 'celluloid/io'

class Arena
  include Celluloid::IO
  finalizer :shutdown

  def initialize(host, port)
    # Inicia o servidor Arena
    puts "Starting Arena at #{host}:#{port}."
    @server = TCPServer.new(host, port)
    @responses = Array.new

    # Variaveis para partilha entre os jogadores
    @bombermans = Hash.new # Utilizado para adicionar cada "bomberman"(jogador)
    @sprites = Hash.new # demais sprites, ou seja, imagens, para desenhar na tela dos demais jogadores    

    # Inicia o servico
    async.run
  end

  # Metodo para encerrar o servidor corretamente 
  def shutdown
    @server.close if @server
  end

  # Metodo para continuar trabalhando as conexoes
  def run
    loop { async.handle_connection @server.accept }
  end

  def backup_of_player message, user
    #criar um backup do jogador, para apaga-lo caso se perca a conexão 
    p "realizando backup of #{@bombermans[user]}" 
    unless @bombermans[user]
      @bombermans[user] = message[1..5]
    end
  end

  def receive_data_of_player message
    p "receive_data_of_player!!!"
    uuid = message[1]

    @sprites[uuid] = message
    p "Colocado na Array @sprites: #{message}"
    #@responses << message
  end

  def send_responses socket
    # p "RESPONSE: #{@responses[0][1]}"
    p "send responses:"
    response = String.new
    @sprites.each_value do |sprite|
      p "Uma resposta: #{sprite}"
      (response << sprite.join("|") << "\n") if sprite
    end
    socket.write response
    p "Writing on socket: #{response}"
    
    #@responses.clear
  end

  # Trabalha cada conexao (jogador)
  def handle_connection(socket)
    # Verifica no socket informacoes da conexao, como ip e porta de origem 
    _, port, host = socket.peeraddr
    user = "#{host}:#{port}"
    puts "#{user} has joined the arena."

    # Verifica as informacoes do socket a cada 4kbytes
    loop do
      data = socket.readpartial(4096)
      data_array = data.split("\n") # "Quebra" as informacoes
    
      # Caso contenha informacoes no socket do jogador
      if data_array and !data_array.empty?
        begin # Utilizado o "begin" para capturar uma excecao
          # Para cada informacao quebrada, leia a linha "row"(basicamente cada "sprite")
          
          data_array.each do |row|
            # Agora vamos separar cada atributo dessa "row"(sprite)
            message = row.split("|")
            
            if message[0] == 'del' # Quando precisa remover uma imagem
              @sprites.delete uuid
            end
            self.method("receive_data_of_"+message[0]).call message
            self.method("backup_of_"+message[0]).call message, user

            send_responses socket
          end
        rescue Exception => exception
          # imprime a excecao qualquer
          puts exception.backtrace
        end
      end # end data    
    end # end loop
  rescue EOFError => err
    # um "catch" para caso o jogador perca conexao
    player = @bombermans[user]
    uuid = player[0]
    p "#{user} has left arena.."
    @sprites.delete uuid
    @bombermans.delete user
    socket.close
  end
end

# Inicia a propria classe e carrega o servidor
server, port = ARGV[0] || "0.0.0.0", ARGV[1] || 5532
supervisor = Arena.supervise({args: [server, port.to_i]})
trap("INT") do
  supervisor.terminate
  exit
end

sleep

