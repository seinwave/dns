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
        expect(query.question_to_bytes(question)).to eq('www.google.com\x00\x01\x00\x01')
       
    end

    it "should encode a reasonable-length domain name" do
        query = Query.new
        expect(query.encode_dns_name("www.google.com")).to eq('\x03www\x06google\x03com\x00')
    end

    it "should encode a non-reasonable-length domain name" do
        query = Query.new
        expect(query.encode_dns_name("www.gooasdfasfasfsafasfasdfasfasfsadglegooasdfasfasfsafasfasdfasfasfsadglegooasdfasfasfsafasfasdfasfasfsadglegooasdfasfasfsafasfasdfasfasfsadgle.com")).to eq('\x03www\x8cgooasdfasfasfsafasfasdfasfasfsadglegooasdfasfasfsafasfasdfasfasfsadglegooasdfasfasfsafasfasdfasfasfsadglegooasdfasfasfsafasfasdfasfasfsadgle\x03com\\x00')
    end

    it "should build a valid DNS query" do
        query = Query.new
        expect(query.build_query("www.google.com", 1, 1)).to eq('\x00\x01\x00\x01\x00\x00\x00\x00\x00\x00\x03www\x06google\x03com\x00\x00\x01\x00\x01')
    end
end  