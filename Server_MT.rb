require "socket"


$i = 0

server = TCPServer.open(8005)
printf("Chatserver started on port %d\n", 8005)


#client disconnects when thread dies
while 1
    Thread.fork(server.accept) do |client| 
		##loop do
			line = client.gets
			client.puts line
	    	puts line
	    	sleep
	    ##end
    end #connection dies here
    puts $i += 1
end
