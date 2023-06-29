require 'rspec/autorun'
require_relative 'resolver'
require_relative '../response/response'

describe Resolver do

    before(:each) do
        @r = Resolver.new
        @response = Response.new
      end 

    TYPE_A_BYTES = "\x01"
    TYPE_NS_BYTES = "\x02"
    TYPE_A_INT = 1
    TYPE_NS_INT = 2
    TYPE_TXT_INT = 16 
    CLASS_INTERNET_INT = 1

    raw_type_a_response = "\x13\x14\x81\x80\x00\x01\x00\x01\x00\x00\x00\x00\x03www\aexample\x03com\x00\x00\x01\x00\x01\xC0\f\x00#{TYPE_A_BYTES}\x00\x01\x00\x00P[\x00\x04]\xB8\xD8\"" 
    raw_type_ns_response = "\x13\x14\x81\x80\x00\x01\x00\x01\x00\x00\x00\x00\x03www\aexample\x03com\x00\x00\x01\x00\x01\xC0\f\x00#{TYPE_NS_BYTES}\x00\x01\x00\x00P[\x00\x04]\xB8\xD8\"" 
    array_of_records = [DNSRecord.new("www.typea.com", 1, 1, 20571, "]\xB8\xD8\""),DNSRecord.new("www.example.com", 1, 2, 20571, "]\xB8\xD8\""),DNSRecord.new("www.example.com", 1, 2, 20571, "]\xB8\xD8\"")]
    packet_with_records = DNSPacket.new(DNSHeader.new(4884,32896,1,1,0),[],array_of_records,[],array_of_records)  
 
    it "should build a valid DNS query" do
        # mock the random id
        allow(@r).to receive(:generate_random_id).and_return(15)
        expect(@r.build_query("www.example.com", 1, 1)).to eq("\u0000\u000F\u0000\u0000\u0000\u0001\u0000\u0000\u0000\u0000\u0000\u0000\u0003www\aexample\u0003com\u0000\u0000\u0001\u0000\u0001")
    end

    it "should send a query, and parse the response" do
        # mock the random id
       allow(@r).to receive(:generate_random_id).and_return(4884)
       packet = @r.send_query("8.8.8.8", "www.example.com", 1, 1)

       packet_ttl = packet.answers[0].ttl

       correct_header = DNSHeader.new(4884,32896,1,1,0)
       correct_record = DNSRecord.new("www.example.com", 1, 1, packet_ttl, "93.184.216.34")
       correct_packet = DNSPacket.new(correct_header, [DNSQuestion.new("www.example.com", 1, 1)], [correct_record],[],[])
       correct_packet.answers[0].data.force_encoding("ASCII-8BIT") # need to force encoding because I copy + pasted the string from the raw response

       expect(packet).to eq(correct_packet)
    end
 
    it "should parse the record, and support TYPE A record types" do
      @buffer = StringIO.new(raw_type_a_response)
      header = @response.parse_header(@buffer)  # have to parse the header first to get the buffer pointer in the right position
      question = @response.parse_question(@buffer) # have to parse the question next, to move the buffer along 

      data_string = "93.184.216.34"
      correct_record = DNSRecord.new("www.example.com", 1, 1, 20571, data_string)
       
      parsed_record = @r.parse_record(@buffer)

      expect(parsed_record).to eq(correct_record)   
    end 

    # it "should parse the record, and support NS (and other) record types" do 
    #   buffer = StringIO.new(raw_type_ns_response)
    #   header = @response.parse_header(buffer)  # have to parse the header first to get the buffer pointer in the right position
    #   question = @response.parse_question(buffer) # have to parse the question next, to move the buffer along
      
    #   record = @r.parse_record(buffer)
    #   encoded_name = "www.example.com".force_encoding("ASCII-8BIT")
    #   expect(record.data).to eq(encoded_name) 
    # end

     it "parses the response, and returns a complete DNSPacket" do
        parsed_packet = @r.parse_dns_packet(raw_type_a_response)

        correct_data_string = "93.184.216.34"
        correct_header = DNSHeader.new(4884,33152,1,1,0)
        correct_record = DNSRecord.new("www.example.com", 1, 1, 20571, correct_data_string)
        correct_packet = DNSPacket.new(correct_header, [DNSQuestion.new("www.example.com", 1, 1)], [correct_record],[],[])
        correct_packet.answers[0].data.force_encoding("ASCII-8BIT") # need to force encoding because I copy + pasted the string from the raw response

        expect(parsed_packet).to eq(correct_packet)
       
    end

    it "should digest packet, and return the first type A answer" do
     
      data = @r.get_answer(packet_with_records)
      expect(data.name).to eq("www.typea.com")
    end

    it "should digest a packet, and return the first type A additional" do
      data = @r.get_nameserver_ip(packet_with_records)
      expect(data.name).to eq("www.typea.com")
    end

    it 'should handle a TXT type request, and return a correct DNS packet' do
      result = @r.send_query("8.8.8.8", "www.example.com", TYPE_TXT_INT, CLASS_INTERNET_INT)
      expect(result.header.num_answers).to eq(2)
    end
    
    it 'should fail to find an answer from a root nameserver' do
      result = @r.send_query("198.41.0.4", "google.com", TYPE_A_INT,CLASS_INTERNET_INT)
      expect(result.header.num_answers).to eq(0)
    end 
    
end  