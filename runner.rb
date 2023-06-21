require_relative 'query/query'
require 'socket'

q = Query.new

query_to_send = q.build_query("www.google.com", 1, 1)


encoded_query = "\x12\x34\x01\x00\x00\x01\x00\x00\x00\x00\x00\x00\x03www\x06google\x03com\x00\x00\x01\x00\x01"
my_query = "\xb5\xad\x01\x00\x00\x01\x00\x00\x00\x00\x00\x00\x03www\x06google\x03com\x00\x00\x01\x00\x01"

puts "my query: #{my_query}"

puts "encoded query: #{encoded_query}"
socket = UDPSocket.new

dns_server_ip = "8.8.8.8"
port = 53

socket.send(my_query, 0, dns_server_ip, port)

response, _ = socket.recvfrom(1024)


socket.close