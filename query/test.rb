require 'rspec/autorun'
require_relative 'query'

describe Query do
    it "should convert a header to bytes" do
        query = Query.new
        header = DNSHeader.new(id:1, flags:1)
        expect(query.header_to_bytes(header)).to eq("\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00")
    end
end  