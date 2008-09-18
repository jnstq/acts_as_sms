require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ShortMessagesController do

  #Delete these examples and add some real ones
  it "should use ShortMessagesController" do
    controller.should be_an_instance_of(ShortMessagesController)
  end


  describe "GET 'index'" do
    it "should be successful" do
      ShortMessage.should_receive(:all)
      get 'index'
      response.should be_success
    end
  end

  describe "GET 'new'" do
    it "should be successful" do
      ShortMessage.should_receive(:new)
      get 'new'
      response.should be_success
    end
  end

  describe "GET 'create'" do
    it "should be successful" do
      short_message = ShortMessage.new
      short_message.should_receive(:save)
      ShortMessage.stub!(:new).and_return(short_message)
      get 'create'
      response.should be_success
    end
  end
end
