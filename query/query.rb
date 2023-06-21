class DNSHeader < Struct.new("DNSHeader", :id, :flags, :num_questions, :num_answers, :num_authorities, :num_additionals)
  def initialize(id: 0, flags: 0, num_questions: 0, num_answers: 0, num_authorities: 0, num_additionals: 0)
    super(id, flags, num_questions, num_answers, num_authorities, num_additionals)
  end
end

class DNSQuestion < Struct.new("DNSQuestion", :name, :type_, :class_)
    def initialize(name: "", type_: 1, class_: 1)
        super(name, type_, class_)
    end
end


class Query 

  def header_to_bytes(header)
    packed = [header.id, header.flags, header.num_questions, header.num_answers, header.num_authorities, header.num_additionals].pack('S>*')
    hex_string = packed.unpack('H*').first
    printable_byte_string = hex_string.scan(/../).map {|b| "\\x" + b }.join
    
    return printable_byte_string
  end
  
  def question_to_bytes(question)

    values = [question.type_ , question.class_]
    packed = values.pack('S>*')
    hex_string = packed.unpack('H*').first
    printable_byte_string = hex_string.scan(/../).map {|b| "\\x" + b }.join
    
    return question.name + printable_byte_string
  end
  
  def encode_dns_name(name)
    encoded_name = ""
    name.split(".").each do |label|
      packed_length = [label.length].pack('C')
      hex_string = packed_length.unpack('H*').first
      string = hex_string.scan(/../).map {|b| "\\x" + b }.join
      encoded_name += string + label
    end
    encoded_name += "\\x00"

    return encoded_name
  end

  def generate_random_id
    return rand(65535)
  end

  def build_query(domain_name, record_type, protocol_class)
    name = encode_dns_name(domain_name)
    id = generate_random_id
    recursion_desired = 1 << 8
    header = DNSHeader.new(id: id, flags: recursion_desired, num_questions: 1)
    question = DNSQuestion.new(name: name, type_: record_type, class_: protocol_class)

    header_bytes = header_to_bytes(header)
    question_bytes = question_to_bytes(question)

    return "#{header_bytes}#{question_bytes}"
  end 

end





