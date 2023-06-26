require 'rspec/autorun'
require_relative 'query'

describe Query do
    it "should convert a header to bytes" do
        query = Query.new
        header = DNSHeader.new(1, 1)
        expect(query.header_to_bytes(header)).to eq("\x00\x01\x00\x01\x00\x00\x00\x00\x00\x00\x00\x00")
    end

    it  "should convert a question to bytes" do
        query = Query.new
        question = DNSQuestion.new("www.google.com", 1, 1)
        expect(query.question_to_bytes(question)).to eq("www.google.com\u0000\u0001\u0000\u0001")
    end

    it "should encode a domain name" do
        query = Query.new
        expect(query.encode_dns_name("www.google.com")).to eq("\u0003www\u0006google\u0003com\u0000")
    end


    it "should build a valid DNS query" do
        query = Query.new
        # mock the random id
        allow(query).to receive(:generate_random_id).and_return(15)
        expect(query.build_query("www.example.com", 1, 1)).to eq("\x00\x0F\x01\x00\x00\x01\x00\x00\x00\x00\x00\x00\x03www\aexample\x03com\x00\x00\x01\x00\x01")
    end
end  