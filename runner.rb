require_relative 'query/query'
require 'socket'
require 'pry'

q = Query.new

query = q.build_query("www.example.com", 1, 1)

socket = UDPSocket.new

dns_server_ip = "8.8.8.8"
port = 53

socket.send(query, 0, dns_server_ip, port)

response, _ = socket.recvfrom(1024)

socket.close