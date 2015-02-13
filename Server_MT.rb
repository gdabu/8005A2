require "socket"


$i = 0

server = TCPServer.open(8005)
printf("Chatserver started on port %d\n", 8005)

mutex = Mutex.new

connections = []

#client disconnects when thread dies
while 1
   	Thread.fork(server.accept) do |client| 
		#puts $i += 1
		connections.push(client)
		puts connections.length
		loop do


			line = client.gets
			client.puts line
			puts line
			
			if client.eof?
				mutex.synchronize do
					connections.delete(client)
					puts connections.length
				end
				break
			end
	    end
	    
    end #connection dies here
    
end
