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

  def method_player message
    @responses << "player"
  end

  def send_responses socket
    p "RESPONSE: #{@responses}"
    @responses.each do |response|
      socket.write response
    end
    @responses.clear
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
            self.method("method_"+message[0]).call message

            # # Verifica o tamanho do array final para se certificar que é o padrao de objeto [msg_type, uuid, x, y]
            # if message.size == 5
            #   puts "atributte: #{message[4]}"
            #   uuid = message[1] # A segunda posicao do array sempre devera ser o uuid
            #   case message[0] # A primeira posicao do array é o tipo de mensagem, ou seja, o que devemos fazer com essa informação 
            #   when 'player' # Cria o jogador em si para espalhar na rede
            #     # Cria uma variavel para deletar as sprites desse player, caso haja algum problema de conexão
            #     unless @bombermans[user]
            #       @bombermans[user] = message[1..4]
            #       puts "uuid #{uuid} to #{user} saved"

            #     end
            #     @sprites[uuid] = message[1..4] # Cria o sprite na rede
            #   when 'del' # Quando precisa remover uma imagem
            #     @sprites.delete uuid
            #   end
            # end

            # Cria a resposta e envia no socket
            # response = String.new
            # # # Faz com que cada sprite esteja em uma nova linha para entregar na rede e fazer o "parse" mais facil
            # # @sprites.each_value do |sprite|
            # #   (response << sprite.join("|") << "\n") if sprite
            # # end
            # socket.write response # Escreve a resposta no socket
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
    puts "#{player[0]} has left arena."
    @sprites.delete player[0]
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

