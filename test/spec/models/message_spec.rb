require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Message do
  before(:each) do
    @valid_attributes = {
      :destination => "0046707293274",
      :body => "Message",
      :originator_type => "numeric",
      :originator => "46707293274",
      :message_type => "text"
    }
  end

  it "should create a new instance given valid attributes" do
    Message.create!(@valid_attributes)
  end

  describe "assosiations" do
    before(:each) do
      @message = Message.new
    end
    it "should have many receipts" do
      @message.should have_many(:delivery_receipts)
    end
  end

  describe "validation" do
    describe "destination" do
      before(:each) do
        @message = Message.new(@valid_attributes)
      end
      it "should be valid destination number" do
        @message.destination = "0046707293274"
        @message.should be_valid
      end
      it "should not be valid destination number" do
        @message.destination = "0707293274"
        @message.should_not be_valid
      end
      
    end
    describe "body" do
      it "should allow up to 918 chars when concat is set to 6" do
        Message.acts_as_sms_options[:allow_concat] = 6
        @message = Message.new(@valid_attributes.merge(:body => "a" * 918))
        @message.should be_valid
      end
      it "should allow 919 chars when concat is set to 6" do
        Message.acts_as_sms_options[:allow_concat] = 6
        @message = Message.new(@valid_attributes.merge(:body => "a" * 919))
        @message.should_not be_valid
      end
      it "should allow 160 chars" do
        Message.acts_as_sms_options[:allow_concat] = 1
        @message = Message.new(@valid_attributes.merge(:body => "a" * 160))
        @message.should be_valid
      end
      it "should not allow more then 160 chars" do
        Message.acts_as_sms_options[:allow_concat] = 1
        @message = Message.new(@valid_attributes.merge(:body => "a" * 161))
        @message.should_not be_valid
      end
    end

    describe "orginator_type" do
      it "should not allow blank else as originator type" do
        @message = Message.new(@valid_attributes.merge(:originator_type => ""))
        @message.should_not be_valid
      end
      it "should not allow nil else as originator type" do
        @message = Message.new(@valid_attributes)
        @message.originator_type = nil
        @message.should_not be_valid
      end

      describe "numeric" do
        before(:each) do
          @message = Message.new(@valid_attributes.merge(:originator_type => 'numeric'))
        end
        it "should be valid" do
          @message.should be_valid
        end
        it "should allow up to 15 chars" do
          @message.should validate_length_of(:originator, :within => 1..15)
        end
        it "should validate format of originator" do
          @message.originator = "0046707293274"
          @message.should_not be_valid
        end
        it "should be valid format of originator" do
          @message.originator = "46707293274"
          @message.should be_valid
        end
      end

      describe "shortcode" do
        before(:each) do
          @message = Message.new(@valid_attributes.merge(:originator_type => "shortcode"))
        end
        it "should allow shortcode as originator type" do
          @message.should be_valid
        end
        it "should allow up to 15 chars" do
          @message.should validate_length_of(:originator, :within => 1..15)
        end
      end

      describe "alpha" do
        before(:each) do
          @message = Message.new(@valid_attributes.merge(:originator_type => "alpha"))
        end
        it "should allow shortcode as originator type" do
          @message.should be_valid
        end
        it "should allow up to 11 chars" do
          @message.should validate_length_of(:originator, :within => 1..11)
        end
        it "should validate format of originator" do
          @message.originator = "Equipe"
          @message.should be_valid
        end
        it "should not be valid format of originator" do
          @message.originator = "1234567890123"
          @message.should_not be_valid
        end
      end
    end

  end

  describe "default settings" do
    before(:each) do
      @message = Message.new
    end
    it "should have default settings for type given at setup" do
      @message.message_type.should eql('text')
    end
    it "should have default settings for originator type given at setup" do
      @message.originator_type.should eql('alpha')
    end
    it "should have default settings for originator given at setup" do
      @message.originator.should eql('Equipe')
    end
    it "should have default setting for allow concat" do
      @message.acts_as_sms_options[:allow_concat].should eql(6)
    end
    it "should have max body text length" do
      Message.acts_as_sms_options[:allow_concat] = 6
      @message.max_length.should eql(918) # 6 * 153
    end
    it "should have max body text dependent on allow concat" do
      Message.acts_as_sms_options[:allow_concat] = 1
      @message.max_length.should eql(160)
    end
  end
  
  describe "configuration file from disk" do
    it "should raise error if configuration file is not found" do
      File.stub!(:exist?).and_return(false)
      lambda {
        Message.sms_configuration
      }.should raise_error
    end
    
    it "should load configuration" do
      Message.instance_eval { @sms_configuration = nil }
      File.stub!(:exist?).and_return(true)
      YAML.should_receive(:load).once.and_return({"sms_url"=>"http://...", "username"=>"user", "password"=>"pass"})
      Message.sms_configuration
    end
  end
  
  describe "send message" do
    
    before(:each) do
      @message = Message.new(@valid_attributes)
      @message.class.stub!(:post).and_return("OK: fc444ec93ac7ebdf6a93816a11d23041")
    end
    
    it "should send a standard sms with less then 160 chars" do
      @message.class.should_receive(:post).and_return("OK: fc444ec93ac7ebdf6a93816a11d23041")
      @message.send_message
    end
    
    it "should create a delivery receipt with response from cellsynt" do
      @message.send_message
      @message.should have(1).delivery_receipts
    end
    
    it "should know that the message is sent" do
      @message.send_message
      @message.should be_sent
    end
    
    it "should not be sent" do
      @message.should_not be_sent
    end
    
  end

end
