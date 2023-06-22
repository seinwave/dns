require_relative 'query/query'
require 'socket'
require 'pry'

q = Query.new

query = q.build_query("www.floogle.com", 1, 1)

query_to_send = query.encode('UTF-8','ASCII')

puts query
puts query.to_s
puts "#{query}"


encoded_query = "\x12\x34\x01\x00\x00\x01\x00\x00\x00\x00\x00\x00\x03www\x06google\x03com\x00\x00\x01\x00\x01"

my_query = "\xfa\xbf\x01\x00\x00\x01\x00\x00\x00\x00\x00\x00\x03www\x07floogle\x03com\x00\x00\x01\x00\x01"

socket = UDPSocket.new

dns_server_ip = "8.8.8.8"
port = 53

socket.send(my_query, 0, dns_server_ip, port)

response, _ = socket.recvfrom(1024)

binding.pry

socket.close