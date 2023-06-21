require 'rspec/autorun'
require_relative 'query'

describe Query do
    it "should convert a header to bytes" do
        query = Query.new
        header = DNSHeader.new(id:1, flags:1)
        expect(query.header_to_bytes(header)).to eq('\x00\x01\x00\x01\x00\x00\x00\x00\x00\x00\x00\x00')
    end

    it  "should convert a question to bytes" do
        query = Query.new
        question = DNSQuestion.new(name: "www.google.com", type_: 1, class_: 1)
        expect(query.question_to_bytes(question)).to eq('\x06google\x03com\x00')
    end
end  