require 'rspec/autorun'
require_relative 'resolver'

describe Resolver do

    before(:each) do
        @r = Resolver.new
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
end  