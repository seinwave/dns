require_relative 'query/query'
require_relative 'response/response'
require_relative 'resolver/resolver'
require 'stringio'
require 'socket'
require 'pry'

@q = Query.new
@r = Response.new 
@resolver = Resolver.new

puts "Enter a url: "
url = gets.chomp

puts "Fetching ip address for #{url}..."

final_ip = @resolver.resolve(url,1)

system "echo #{final_ip} | pbcopy"

puts "IP address copied to clipboard: #{final_ip}"

