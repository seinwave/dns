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
    packed = [header.id, header.flags, header.num_questions, header.num_answers, header.num_authorities, header.num_additionals].pack('S>S>S>S>S>S>')
    hex_string = packed.unpack('H*').first
    printable_byte_string = hex_string.scan(/../).map {|b| '\x' + b }.join
    return printable_byte_string
  end
  
  def question_to_bytes(question)
    packed = [question.type_ , question.class_].pack('L>')
    hex_string = packed.unpack('H*').first
    printable_byte_string = hex_string.scan(/../).map {|b| '\x' + b }.join
    
    return question.name + printable_byte_string
  end
  
  
  def encode_dns_name(domain_name)
  end

end 





