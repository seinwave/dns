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

  def parse_record(reader)
    name = @response.decode_name(reader)

    type_and_class_bytes = reader.read(4)  # type and class are both 2 bytes
    type_, class_ = type_and_class_bytes.unpack("n2")

    ttl_bytes = reader.read(4)
    ttl = ttl_bytes.unpack("N")[0] # ttl is 4 bytes

    data_length_bytes = reader.read(2) # data length is 2 bytes
    data_length = data_length_bytes.unpack("n")[0] # tells us how many bytes of data to consume
    data = reader.read(data_length) # data is what we're after -- the ip address, or the name server, or the mail server, etc   

    return DNSRecord.new(name, type_, class_, ttl, data)
  end

end 