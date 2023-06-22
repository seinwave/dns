require_relative '../query/query'
require 'stringio'

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

 
 def decode_name(reader)
    name = ""
    loop do
      length = reader.read(1).unpack("C")[0]
      break if length == 0
      name += reader.read(length) + "."
    end
    return name
  end

end  
