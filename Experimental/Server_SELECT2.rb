require "socket"
require "thread"
require 'thwait'

################
# - Variables
################
HOST = 'localhost'
PORT = 8005
$descriptors = []
$acceptor = []
serverSocket = TCPServer.open( PORT )
serverSocket.setsockopt( Socket::SOL_SOCKET, Socket::SO_REUSEADDR, 1 )
$messageCount = 0
$threads = []

STDOUT.sync = true

################
# - FUNCTIONS
################
def killConnection( clientSocket, connections )
	clientSocket.close
	connections.delete(clientSocket)
	puts connections.length - 1
end

################
# - SERVER ENTRY
################

puts "Echo server listening on #{HOST}:#{PORT}"
$descriptors.push( serverSocket )
$acceptor.push( serverSocket )


$threads = Thread.fork() do 
	while 1
		serverSocketFD = IO.select($acceptor)
		if serverSocketFD != nil then
			newClientSocket = serverSocket.accept_nonblock()
			$descriptors.push( newClientSocket )
		end
	end
end

$threads = Thread.fork() do 
	while 1 

		#connection is assigned an array of arrays of file descriptors
		#select returns all the file descriptors (i.e. sockets) that are available to be read from in the descriptors array
		connection = IO.select($descriptors)

		if connection != nil then
			for sock in connection[0]
				if sock == serverSocket then

				else
					if sock.eof? 
						killConnection( sock, $descriptors )
					else
						data = sock.gets
						sock.puts("#{data}")
						sock.flush
						puts ("#{data.chomp} #{$messageCount += 1}")
					end #end ifelse
				end
			end #end for
		end #end if 
	end #end while 1
end


STDIN.gets
ThreadsWait.all_waits(*$threads)
