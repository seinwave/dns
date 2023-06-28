require_relative 'query/query'
require_relative 'response/response'
require 'stringio'
require 'socket'
require 'pry'

q = Query.new
r = Response.new 

puts "Enter a url: "
url = gets.chomp

puts "Fetching ip address for #{url}..."

query = q.build_query(url, 1, 1)

socket = UDPSocket.new

dns_server_ip = "8.8.8.8" # start with google's dns server
port = 53

socket.send(query, 0, dns_server_ip, port)

response, _ = socket.recvfrom(1024)

packet = r.parse_dns_packet(response)

response_data = packet.answers[0].data

ip_address = r.get_ip_address(response_data)

system "echo #{ip_address} | pbcopy"

puts "IP address copied to clipboard: #{ip_address}"

socket.close