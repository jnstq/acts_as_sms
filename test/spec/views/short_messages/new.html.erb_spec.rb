require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/short_messages/new" do
  before(:each) do
    assigns[:short_message] = ShortMessage.new
    render 'short_messages/new'
  end
  
  #Delete this example and add some real ones or delete this file
  it "should tell you where to find the file" do
    response.should have_tag('form', %r[Message])
  end
end
