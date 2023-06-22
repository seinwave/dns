require_relative '../query/query'
require 'stringio'

q = Query.new


class DNSRecord < Struct.new("DNSRecord", :name, :type_, :class_, :ttl, :data)
  def initialize(name: "", type_: 0, class_: 0, ttl: 0, data: "")
    super(name, type_, class_, ttl, data)
  end
end

class Response 
  def parse_header(reader)

  end
end  
