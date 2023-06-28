require 'rspec/autorun'
require_relative 'resolver'
require_relative '../response/response'

TYPE_A = "\x01"
TYPE_NS = "\x02"

describe Resolver do

    before(:each) do
        @r = Resolver.new
        @response = Response.new
        @raw_type_a_response = "\x13\x14\x81\x80\x00\x01\x00\x01\x00\x00\x00\x00\x03www\aexample\x03com\x00\x00\x01\x00\x01\xC0\f\x00#{TYPE_A}\x00\x01\x00\x00P[\x00\x04]\xB8\xD8\"" 
        @raw_type_ns_response = "\x13\x14\x81\x80\x00\x01\x00\x01\x00\x00\x00\x00\x03www\aexample\x03com\x00\x00\x01\x00\x01\xC0\f\x00#{TYPE_NS}\x00\x01\x00\x00P[\x00\x04]\xB8\xD8\"" 
    end 
 
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
       correct_record = DNSRecord.new("www.example.com", 1, 1, packet_ttl, "]\xB8\xD8\"")
       correct_packet = DNSPacket.new(correct_header, [DNSQuestion.new("www.example.com", 1, 1)], [correct_record],[],[])
       correct_packet.answers[0].data.force_encoding("ASCII-8BIT") # need to force encoding because I copy + pasted the string from the raw response

       expect(packet).to eq(correct_packet)
    end
 
    it "should parse the record, and support TYPE A record types" do
      @buffer = StringIO.new(@raw_type_a_response)
      header = @response.parse_header(@buffer)  # have to parse the header first to get the buffer pointer in the right position
      question = @response.parse_question(@buffer) # have to parse the question next, to move the buffer along 

      data_string = "93.184.216.34"
      correct_record = DNSRecord.new("www.example.com", 1, 1, 20571, data_string)
       
      parsed_record = @r.parse_record(@buffer)

      expect(parsed_record).to eq(correct_record)   
    end 

    it "should parse the record, and support NS (and other) record types" do 
      buffer = StringIO.new(@raw_type_ns_response)
      header = @response.parse_header(buffer)  # have to parse the header first to get the buffer pointer in the right position
      question = @response.parse_question(buffer) # have to parse the question next, to move the buffer along
      
      record = @r.parse_record(buffer)
      encoded_name = "www.example.com".force_encoding("ASCII-8BIT")
      expect(record.data).to eq(encoded_name) 
    end

     it "parses the response, and returns a complete DNSPacket" do
        parsed_packet = @r.parse_dns_packet(@raw_type_a_response)

        correct_data_string = "93.184.216.34"
        correct_header = DNSHeader.new(4884,33152,1,1,0)
        correct_record = DNSRecord.new("www.example.com", 1, 1, 20571, correct_data_string)
        correct_packet = DNSPacket.new(correct_header, [DNSQuestion.new("www.example.com", 1, 1)], [correct_record],[],[])
        correct_packet.answers[0].data.force_encoding("ASCII-8BIT") # need to force encoding because I copy + pasted the string from the raw response

        expect(parsed_packet).to eq(correct_packet)
       
    end
    
end  