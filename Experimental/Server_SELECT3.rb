require "socket"
require "thread"
require 'thwait'

################
# - Variables
################
HOST = 'localhost'
PORT = 8005
$descriptors = [[],[],[]]

$serverSocket = TCPServer.open( PORT )
$serverSocket.setsockopt( Socket::SOL_SOCKET, Socket::SO_REUSEADDR, 1 )
$messageCount = 0
$threads = []

i = 0

STDOUT.sync = true

################
# - FUNCTIONS
################
def killConnection( clientSocket, connections )
	clientSocket.close
	connections.delete(clientSocket)
	puts connections.length - 1
end

def threadedSelect( socketlist )
	
	$threads = Thread.fork() do 
		while 1 

			#connection is assigned an array of arrays of file descriptors
			#select returns all the file descriptors (i.e. sockets) that are available to be read from in the descriptors array
			connection = IO.select(socketlist)
			if connection != nil then
				for sock in connection[0]
					if sock == $serverSocket then

					else
						if sock.eof? 
							killConnection( sock, socketlist )
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

end

################
# - SERVER ENTRY
################

puts "Echo server listening on #{HOST}:#{PORT}"
$descriptors[0].push( $serverSocket )
$descriptors[1].push( $serverSocket )
$descriptors[2].push( $serverSocket )


$threads = Thread.fork() do 
	while i < 3

		newClientSocket = $serverSocket.accept()
		$descriptors[i].push( newClientSocket )
		
		i += 1
		if i == 3
			i = 0
		end
	end
end

threadedSelect($descriptors[0])
threadedSelect($descriptors[1])
threadedSelect($descriptors[2])


puts "main waiting"
STDIN.gets
ThreadsWait.all_waits(*$threads)
