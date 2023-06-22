require 'rspec/autorun'
require_relative 'response'

describe Response do

    before(:each) do
        @response = Response.new
        @raw_response = "\x00\x01\x81\x80\x00\x01\x00\x01\x00\x00\x00\x00\x03www\aexample\x03com\x00\x00\x01\x00\x01\xc0\x0c\x00\x01\x00\x01\x00\x00\x00\x00\x00\x04\x00\x04\x7f\x00\x00\x01"
    end
    
    it "parse a header, and return a new DNSRecord" do
        @buffer = StringIO.new(@raw_response)
        expect(@response.parse_header(@buffer)).to eq(DNSRecord.new(1, 1, 1, 0, 0))
    end

end 