require_relative '../query/query'
require 'stringio'

class DNSRecord < Struct.new("DNSRecord", :name, :type_, :class_, :ttl, :data)
  def initialize(name, type_, class_ = 1, ttl, data)
    super(name, type_, class_, ttl, data)
  end
end

class DNSPacket < Struct.new("DNSPacket", :header, :questions, :answers, :authorities, :additionals)
  def initialize(header, questions, answers, authorities, additionals)
    super(name, type_, class_, ttl, data)
  end
end

class Response 
  def parse_header(reader)
      items = reader.read(12).unpack("n6")
      
      return DNSHeader.new(*items)
  end

 
 def decode_name(reader)
    name = [] 
    loop do
      length = reader.read(1).unpack("C")[0]
      if (length & 0xC0) == 0xC0 # checking if most significant bits are 11 - means we have a compressed name (ie - a reference to the position of the name in the bytestream)
        name.push(decode_compressed_name(length, reader))
        break # a compressed name is never followed by another label
      else 
        break if length == 0
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

  def parse_question(reader)
    name = decode_name(reader)
    data = reader.read(4)
    type_, class_ = data.unpack("n2")
    
    return DNSQuestion.new(name, type_, class_)
  end

  def parse_record(reader)
    name = decode_name(reader)

    type_and_class_bytes = reader.read(4)  # type and class are both 2 bytes
    type_, class_ = type_and_class_bytes.unpack("n2")

    ttl_bytes = reader.read(4)
    ttl = ttl_bytes.unpack("N")[0] # ttl is 4 bytes

    data_length_bytes = reader.read(2) # data length is 2 bytes
    data_length = data_length_bytes.unpack("n")[0] # tells us how many bytes of data to consume
    data = reader.read(data_length)

    return DNSRecord.new(name, type_, class_, ttl, data)
  end

end  
