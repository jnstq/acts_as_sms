require File.dirname(__FILE__) + '/../spec_helper'

describe IncomingShortMessage do
  before(:each) do
    @valid_attributes = {
      "country" => 'se',
      "operator" => 'telia',
      "shortcode" => '72456',
      "sender" => '0046700123456',
      "text" => 'ABC+test!',
      "sessionid" => '1:1136364712521:0046700123456'
    }
  end

  it "should create a new sms" do
    IncomingShortMessage.should_receive(:create!).with(@valid_attributes)
    IncomingShortMessage.incoming! @valid_attributes
  end

  it "should ignore unknown attributes" do
    IncomingShortMessage.should_receive(:create!).with(@valid_attributes)
    IncomingShortMessage.incoming! @valid_attributes.merge(:action => 'incoming', :user_path => true)
  end
  
  it "should not create unless attribtues is present" do
    lambda {
      IncomingShortMessage.incoming! @valid_attributes.keys.inject({}) {|r, v| r[v] = nil; r }
    }.should_not change(IncomingShortMessage, :count)
  end
end
