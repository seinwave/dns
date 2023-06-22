require_relative 'query/query'
require_relative 'response/response'
require 'stringio'
require 'socket'
require 'pry'

q = Query.new
r = Response.new 

query = q.build_query("www.example.com", 1, 1)

socket = UDPSocket.new

dns_server_ip = "8.8.8.8"
port = 53

socket.send(query, 0, dns_server_ip, port)

response, _ = socket.recvfrom(1024)

reader = StringIO.new(response)

header = r.parse_header(reader)

puts header.inspect

socket.close