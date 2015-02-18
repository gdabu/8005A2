require "socket"
require 'thread'
require 'thwait'

################
# - Variables
################
HOST = ARGV[0]
PORT = ARGV[1]
$totalClients = Integer(ARGV[2])
$totalMessages = Integer(ARGV[3])

$i = 0
threads = []

STDOUT.sync = true


while $i < $totalClients
	puts $i += 1
	threads = Thread.fork() do
		begin
			server = TCPSocket.open(HOST, PORT)
			
			$totalMessages.times do
				server.write("hellogeoff\n")
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
