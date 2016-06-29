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

    # Variaveis para partilha entre os jogadores
    @bombermans = Hash.new # Utilizado para adicionar cada "bomberman"(jogador)
    @sprites = Hash.new # demais sprites, ou seja, imagens, para desenhar na tela dos demais jogadores    

    # Inicia o servico
    async.run

    @uuid = ''
  end

  # Metodo para encerrar o servidor corretamente 
  def shutdown
    @server.close if @server
  end

  # Metodo para continuar trabalhando as conexoes
  def run
    loop { async.handle_connection @server.accept }
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
            @uuid = message[1]
            if message[0] == 'del' # Quando precisa remover uma imagem
              @sprites.delete uuid
            end

            self.method("receive_data_of_"+message[0]).call message
            p "Message vindo da Arena: #{message}"
            #self.method("backup_of_"+message[0]).call message, user

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
    # uuid = @bombermans[user][0]
    p "#{user} has left arena.. e Sprite[#{@uuid}] será deletada!!"
    @sprites.delete @uuid
    @sprites << "die"
    @bombermans.delete user
    socket.close
  end

  def receive_data_of_player message
    uuid = message[1]
    # method = message[4]

    @sprites[uuid] = message

    p "Inserindo @sprites[#{uuid}]: #{message}"
  end

  # #criar um backup do jogador, para apaga-lo caso se perca a conexão 
  # def backup_of_player message, user
  #   # p "realizando backup of #{@bombermans[user]}" 
  #   unless @bombermans[user]
  #     @bombermans[user] = message[1..5]
  #   end
  # end

  def send_responses socket
    response = String.new
    @sprites.each do |key, sprite|
      response << sprite.join("|") << "\n" if sprite
      p "Uma resposta response: #{response}"
    end
    socket.write response
    p "send responses: --- o/ #{response}"

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

