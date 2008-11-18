require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe IncomingShortMessagesController do
  integrate_views
  
  before(:each) do
    @valid_incoming_sms = {
      "country" => 'se',
      "operator" => 'telia',
      "shortcode" => '72456', 
      "sender" => '0046700123456',
      "text" => 'ABC+test!',
      "sessionid" => '1:1136364712521:0046700123456'
    }
  end
  
  describe "GET 'incoming'" do
    it "should be successful" do
      get :incoming
      response.should be_success
    end
    
    it "should save the incoming sms" do
      IncomingShortMessage.should_receive(:incoming!).with(hash_including(@valid_incoming_sms))      
      get :incoming, @valid_incoming_sms.dup
    end
  end
  
end