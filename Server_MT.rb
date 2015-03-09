#/*---------------------------------------------------------------------------------------
#--	SOURCE FILE: 	Server_MT.rb - A simple TCP server using multiple threads
#--
#--	PROGRAM:		Server_MT.rb
#--					ruby Server_MT.rb
#--
#--	FUNCTIONS:		Select Echo Server
#--
#--	DATE:			February 23, 2015
#--
#--	DESIGNERS:		GEOFF DABU
#--	PROGRAMMERS:	GEOFF DABU, CHRIS HUNTER
#--
#-- NOTES:        This server uses multiple threads to read and write 
#--               messages to and from the client.
#--
#--	CLIENT: client.rb
#---------------------------------------------------------------------------------------*/
require "socket"
require "logger"
require_relative "ServerFunctions.rb"

#------------------------
#-- Variable Declaration
#------------------------
begin
	HOST = ARGV[0]
	PORT = ARGV[1]
	READBUFFERSIZE = Integer(ARGV[2])
rescue Exception => argException
  	puts ">> Illegal Arguments"
  	puts ">> Usage: ruby client.rb (serverIP serverPort readBufferSize)"
  	exit
end

descriptors = []
serverSocket = TCPServer.new( PORT )
serverSocket.setsockopt( Socket::SOL_SOCKET, Socket::SO_REUSEADDR, 1 )
mutex = Mutex.new
STDOUT.sync = true

$maxNumberOfClients = 0
$numberOfClientRequests = 0
$numberOfBytesSent = 0

#Initialize log files
file = File.new('Server_MT.log', 'w')
logger = Logger.new(file)

#----------------
#-- Server Entry 
#----------------
puts "Echo server listening on #{HOST}:#{PORT}"

begin

#client disconnects when thread dies
while 1
	#create a thread for every new connection
   	Thread.new(serverSocket.accept) do |clientSocket| 
		
		descriptors.push(clientSocket)
		puts descriptors.length

		logger.info('NEW_CONNECTION') { "	#{Socket.unpack_sockaddr_in(clientSocket.getpeername)}" }

        if descriptors.length > $maxNumberOfClients
			$maxNumberOfClients = descriptors.length
		end #end if
		
		while 1

			sentMessage = echoMessage(clientSocket, READBUFFERSIZE)
			$numberOfClientRequests += 1
			$numberOfBytesSent += sentMessage.bytesize

			logger.info('CLIENT_REQUEST') { "	#{Socket.unpack_sockaddr_in(clientSocket.getpeername)}: #{$numberOfClientRequests}" }
			logger.info('SENDING_DATA') { "	#{Socket.unpack_sockaddr_in(clientSocket.getpeername)}: #{sentMessage.bytesize}" }

			#Client kills connection
			if clientSocket.eof?
				#killConnection is put into a mutex so that disconnections are made 1-by-1
				mutex.synchronize do
					killConnection( clientSocket, descriptors )
				end
				break #break here to leave thread block, hence ending thread
			end #end if
	    end #end while
    end #end connection
end #end 

rescue Exception => e
	puts ">> #{e.message}"
	puts ">> Server Failure"
ensure
	puts "------------------------------------------------"
	puts "Maximum Number of Concurrent Clients: #{$maxNumberOfClients}"
  	puts "Total Number of Client Requests Received: #{$numberOfClientRequests}"
  	puts "Total Number of Bytes Sent: #{$numberOfBytesSent}"
	puts "------------------------------------------------"

	logger.info('FINAL_RESULTS'){"------------------------------------------------"}
	logger.info('FINAL_RESULTS'){"Maximum Number of Concurrent Clients: #{$maxNumberOfClients}"}
	logger.info('FINAL_RESULTS'){"Total Number of Client Requests Received: #{$numberOfClientRequests}"}
	logger.info('FINAL_RESULTS'){"Total Number of Bytes Sent: #{$numberOfBytesSent}"}
	logger.info('FINAL_RESULTS'){"------------------------------------------------"}

	logger.close
end #end begin rescue ensure





