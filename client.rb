require "socket"
require 'thread'
require 'thwait'

################
# - Variables
################
$totalClients = Integer(ARGV[0])
$totalMessages = Integer(ARGV[1])
HOST = 'localhost'
PORT = 8005
$i = 0
threads = []



while $i < $totalClients
	puts $i += 1
	threads = Thread.fork() do
		begin
			server = TCPSocket.open(HOST, PORT)
			
			$totalMessages.times do
				server.write ("hellogeoff\n")
				line = server.gets
				STDOUT.puts line
			end

			sleep
			#server.close
		rescue Exception => e 
			puts "Exception:: " + e.message + "\n"
			exit
		end
	end
	sleep(0.005)
end

STDIN.gets
ThreadsWait.all_waits(*threads)
