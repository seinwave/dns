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

    return parse_dns_packet(response)
  end 

  def decode_name(reader)
    name = []
    loop do
      length = reader.read(1).unpack("C")[0]
      if (length & 0xC0) == 0xC0 # checking if most significant bits are 11 - means we have a compressed name (ie - a reference to the position of the name in the bytestream)
        name.push(decode_compressed_name(length, reader))
        return name.join(".")
      elsif length == 0
        return name.join(".") 
      else 
        name.push(reader.read(length))
      end 
    end

    return name.join(".")

  end

  def decode_compressed_name(length, reader)
    last_six_bits_of_length = ((length & 0x3F) << 8)  
    next_byte_int = reader.read(1).unpack("C")[0]
    pointer = last_six_bits_of_length + next_byte_int  # pointer is the position of the name in the bytestream

    saved_position = reader.pos
    reader.pos = pointer
    result = decode_name(reader)
    reader.pos = saved_position # restore the reader's original position     
    
    return result
  end

  def parse_record(reader)
    return if reader.nil?

    type_a = 1
    type_ns = 2

    name = decode_name(reader)

    type_and_class_bytes = reader.read(4)  # type and class are both 2 bytes
    type_, class_ = type_and_class_bytes.unpack("n2")

    ttl_bytes = reader.read(4)
    ttl = ttl_bytes.unpack("N")[0] # ttl is 4 bytes
    
    data_length_bytes = reader.read(2) # data length is 2 bytes
    data_length = data_length_bytes.unpack("n")[0] # tells us how many bytes of data to consume

    if type_ == type_ns 
      data = decode_name(reader)
    elsif type_ == type_a
      data = @response.get_ip_address(reader.read(data_length)) 
    else 
      data = reader.read(data_length)
    end

    record = DNSRecord.new(name, type_, class_, ttl, data)

    puts record
    return record
  end

  def get_answer(packet)
    packet.answers.each do |answer|
      return answer if answer.type_ == 1
    end 
  end

  def get_nameserver_ip(packet)
    packet.additionals.each do |additional|
      return additional if additional.type_ == 1
    end 
  end 

  def parse_dns_packet(response)
    reader = StringIO.new(response)
    header = @response.parse_header(reader)

    questions = []
    answers = []
    authorities = []
    additionals = []

    header.num_questions.times do
      questions << @response.parse_question(reader)
    end 

    header.num_answers.times do
      answer = parse_record(reader)
      answers << answer
    end

    header.num_authorities.times do
      authority = parse_record(reader)
      authorities << authority
    end

    header.num_additionals.times do
      additional = parse_record(additional)
      additionals << additional
    end 

    return DNSPacket.new(header, questions, answers, authorities, additionals)
  end


end 