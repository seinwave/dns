require 'rspec/autorun'
require_relative 'response'

describe Response do

    before(:each) do
        @response = Response.new
        @raw_response = "\x13\x14\x81\x80\x00\x01\x00\x01\x00\x00\x00\x00\x03www\aexample\x03com\x00\x00\x01\x00\x01\xC0\f\x00\x01\x00\x01\x00\x00P[\x00\x04]\xB8\xD8\""
    end

    it "parses a header, and returns a new DNSHeader" do
        @buffer = StringIO.new(@raw_response)
        expect(@response.parse_header(@buffer)).to eq(DNSHeader.new(4884,33152,1,1,0))
    end

    it "parses a response, and returns the domain name" do
        @buffer = StringIO.new(@raw_response)
        @response.parse_header(@buffer)  # have to parse the header first to get the buffer pointer in the right position
        expect(@response.decode_name(@buffer)).to eq("www.example.com")
    end
    
    it "parses the question, and returns a new DNSQuestion" do
        @buffer = StringIO.new(@raw_response)
        @response.parse_header(@buffer)  # have to parse the header first to get the buffer pointer in the right position
        expect(@response.parse_question(@buffer)).to eq(DNSQuestion.new("www.example.com", 1, 1))
    end

    it "parses the record, and returns a new DNSRecord" do
        @buffer = StringIO.new(@raw_response)
        header = @response.parse_header(@buffer)  # have to parse the header first to get the buffer pointer in the right position
        question = @response.parse_question(@buffer) # have to parse the question next, to move the buffer along 
        #todo: diff is empty, but the objects are not equal.  why?

        data_string = "]\xB8\xD8\""
        data_string.force_encoding("ASCII-8BIT")
        correct_record = DNSRecord.new("www.example.com", 1, 1, 20571, data_string)
       

        parsed_record = @response.parse_record(@buffer)


        expect(parsed_record).to eq(correct_record)

             
    end 

end 