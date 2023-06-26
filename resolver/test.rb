require 'rspec/autorun'
require_relative 'resolver'

describe Resolver do
 
    it "should build a valid DNS query" do
        r = Resolver.new
        # mock the random id
        allow(r).to receive(:generate_random_id).and_return(15)
        expect(r.build_query("www.example.com", 1, 1)).to eq("\u0000\u000F\u0000\u0000\u0000\u0001\u0000\u0000\u0000\u0000\u0000\u0000\u0003www\aexample\u0003com\u0000\u0000\u0001\u0000\u0001")
    end
end  