require_relative '../query/query'
require_relative '../response/response'
require 'socket'
require 'stringio'


class Resolver 
  def initialize
    @query = Query.new
    @response = Response.new
  end 

  def generate_random_id 
    rand(65535)
  end 

  def build_query(domain_name, record_type, protocol_class)
    name = @query.encode_dns_name(domain_name)
    id = generate_random_id
    recursion_desired = 0 # we don't want recursion, because we're asking an authoritative name server
    header = DNSHeader.new(id, recursion_desired, 1)
    question = DNSQuestion.new(name,record_type, protocol_class)

    header_bytes = @query.header_to_bytes(header)
    question_bytes = @query.question_to_bytes(question)

    query = header_bytes + question_bytes  
    return query.force_encoding("UTF-8")
  end 

  def send_query(ip_address, domain_name, record_type, protocol_class)
    query = build_query(domain_name, record_type, protocol_class)

    socket = UDPSocket.new
    socket.send(query, 0, ip_address, 53)
    response, _ = socket.recvfrom(1024)

    return @response.parse_dns_packet(response)

  end 

end 