require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/short_messages/index" do
  before(:each) do
    assigns[:short_messages] = [ShortMessage.new]
    render 'short_messages/index'
  end
  
  #Delete this example and add some real ones or delete this file
  it "should tell you where to find the file" do
    response.should have_tag('div', %r[Destination])
  end
end
