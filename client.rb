require "socket"
require 'thread'
require 'thwait'



$totalClients = Integer(ARGV[0])

$i = 0
threads = Array::new



while $i < $totalClients
	puts $i += 1
	threads = Thread.fork() do
		begin
			server = TCPSocket.open("localhost", 8005)
			server.puts "hellogeoff"
			line = server.gets
			puts line
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
