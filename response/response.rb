require_relative '../query/query'
require 'stringio'

q = Query.new



class DNSRecord < Struct.new("DNSRecord", :name, :type_, :class_, :ttl, :data)
  def initialize(name, type_, class_ = 1, ttl, data)
    super(name, type_, class_, ttl, data)
  end
end

class Response 
  def parse_header(reader)
      items = reader.read(12).unpack("n5")
      return DNSHeader.new(*items)
  end
end  
