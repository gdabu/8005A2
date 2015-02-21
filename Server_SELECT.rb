#/*---------------------------------------------------------------------------------------
#--	SOURCE FILE: 	Server_SELECT.rb - A simple TCP server using the IO#select api.
#--
#--	PROGRAM:		Server_SELECT.rb
#--					ruby Server_SELECT.rb
#--
#--	FUNCTIONS:		Select Echo Server
#--
#--	DATE:			February 23, 2015
#--
#--	DESIGNERS:		GEOFF DABU
#--	PROGRAMMERS:	GEOFF DABU, CHRIS HUNTER
#--
#-- NOTES:        This server uses the IO.select call  to read and write 
#--               messages to and from the client.
#--
#--	CLIENT: client.rb
#---------------------------------------------------------------------------------------*/
require "socket"
require "logger"
require_relative "serverFunctions"

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
serverSocket = TCPServer.open( PORT )
serverSocket.setsockopt( Socket::SOL_SOCKET, Socket::SO_REUSEADDR, 1 )
STDOUT.sync = true

$maxNumberOfClients = 0
$numberOfClientRequests = 0
$numberOfBytesSent = 0

#Initialize log files
file = File.new('Server_SELECT.log', 'w')
logger = Logger.new(file)

#----------------
#-- Server Entry 
#----------------
puts "Echo server listening on #{HOST}:#{PORT}"
descriptors.push( serverSocket )

begin

while 1 
	#connection is assigned an array of arrays of file descriptors
	#select returns all the file descriptors (i.e. sockets) that are available to be read from in the descriptors array
	connection = IO.select(descriptors)

	if connection != nil then
		
		for socket in connection[0]

			#Server Socket has received a new connection request
			if socket == serverSocket then
					newClientSocket = acceptNewConnectionNonBlock(serverSocket, descriptors)
					logger.info('NEW_CONNECTION') { "	#{Socket.unpack_sockaddr_in(newClientSocket.getpeername)}" }

			        if descriptors.length - 1 > $maxNumberOfClients
          				$maxNumberOfClients = descriptors.length
        			end #end if
			else

				if socket.eof? 
					killConnection( socket, descriptors )
					
				else
					sentMessage = echoMessage( socket, READBUFFERSIZE )
					$numberOfClientRequests += 1
					$numberOfBytesSent += sentMessage.bytesize

					logger.info('CLIENT_REQUEST') { "	#{Socket.unpack_sockaddr_in(socket.getpeername)}: #{$numberOfClientRequests}" }
					logger.info('SENDING_DATA') { "	#{Socket.unpack_sockaddr_in(socket.getpeername)}: #{sentMessage.bytesize}" }

				end #end ifelse
			end #end ifelse
		end #end for
	end #end if 
end #end while 1

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
