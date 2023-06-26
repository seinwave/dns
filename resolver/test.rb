require 'rspec/autorun'
require_relative 'resolver'

describe Resolver do
 
    it "should build a valid DNS query" do
        r = Resolver.new
        # mock the random id
        allow(r).to receive(:generate_random_id).and_return(15)
        expect(r.build_query("www.example.com", 1, 1)).to eq("\x00\x0F\x01\x00\x00\x01\x00\x00\x00\x00\x00\x00\x03www\aexample\x03com\x00\x00\x00\x00\x00")
    end
end  