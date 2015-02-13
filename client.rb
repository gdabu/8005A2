require "socket"
require 'thread'
require 'thwait'



$totalClients = Integer(ARGV[0])
$totalMessages = Integer(ARGV[1])

$i = 0
threads = Array::new



while $i < $totalClients
	puts $i += 1
	threads = Thread.fork() do
		begin
			server = TCPSocket.open("localhost", 8005)
			
			$totalMessages.times do
				server.puts "hellogeoff"
				line = server.gets
				puts line
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
