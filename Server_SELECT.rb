require "socket"

descriptors = []
serverSocket = TCPServer.open( 8005 )
serverSocket.setsockopt( Socket::SOL_SOCKET, Socket::SO_REUSEADDR, 1 )
printf("Chatserver started on port %d\n", 8005)
descriptors.push( serverSocket )

while 1 
	#connection is assigned an array of arrays of file descriptors
	#select returns all the file descriptors (i.e. sockets) that are available to be read from in the descriptors array
	connection = select(descriptors)
	if connection != nil then
		
		for sock in connection[0]

			if sock == serverSocket then
				newSock = serverSocket.accept() 
				descriptors.push( newSock )
				puts descriptors.length
			else
				#---When Client Disconnects---
				if sock.eof? 
					sock.close
					descriptors.delete( sock )
					puts descriptors.length
				#-----------------------------
				else
					str = sock.gets
					sock.puts( str )
					puts str
				end
			end
		end
	end
end #end while 1