require "socket"


################
# - Variables
################
HOST = 'localhost'
PORT = 8005
connections = []
serverSocket = TCPServer.open( PORT )
serverSocket.setsockopt( Socket::SOL_SOCKET, Socket::SO_REUSEADDR, 1 )
$messageCount = 0
mutex = Mutex.new

################
# - FUNCTIONS
################
def killConnection( clientSocket, connections )
	clientSocket.close
	connections.delete(clientSocket)
	puts connections.length
end



puts "Echo server listening on #{HOST}:#{PORT}"

begin

#client disconnects when thread dies
while 1
   	Thread.fork(serverSocket.accept) do |client| 
		connections.push(client)
		puts connections.length
		loop do

			data = client.gets
			client.puts ("M_#{data}")
			puts ("#{data.chomp} #{$messageCount += 1}")

			if client.eof?
				mutex.synchronize do
					killConnection( client, connections )
				end
				break
			end
	    end
    end #end connection
end #end 

rescue Exception => e
end