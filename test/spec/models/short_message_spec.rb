require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ShortMessage do
  before(:each) do
    @valid_attributes = {
      :destination => "0046707293274",
      :body => "ShortMessage",
      :originator_type => "numeric",
      :originator => "46707293274",
      :message_type => "text"
    }
    
    @valid_sms_configuration = {
      "sms_url" => "http://sms.cellsynt.net/sms.php",
      "psms_url" => "http://sms.cellsynt.net/sendsms.php",
      "username"=>"user",
      "password"=>"pass"
    }
  end

  it "should create a new instance given valid attributes" do
    ShortMessage.create!(@valid_attributes)
  end

  describe "assosiations" do
    before(:each) do
      @short_message = ShortMessage.new
    end
    it "should have many receipts" do
      @short_message.should have_many(:delivery_receipts)
    end
  end

  describe "attribute and validation" do
    describe "destination" do
      before(:each) do
        @short_message = ShortMessage.new(@valid_attributes)
      end
      it "should be valid destination number" do
        @short_message.destination = "0046707293274"
        @short_message.should be_valid
      end
      it "should not be valid destination number" do
        @short_message.destination = "0707293274"
        @short_message.should_not be_valid
      end
      it "should validate presence of destination number" do
        @short_message.destination = ""
        @short_message.should_not be_valid
      end
      it "should alias destination to session id" do
        @short_message.destination = "12345"
        @short_message.session_id.should eql("12345")
      end

    end
    describe "body" do
      it "should validate precense of body" do
        @short_message = ShortMessage.new(@valid_attributes.merge(:body => ""))
        @short_message.should_not be_valid
      end
      it "should allow up to 918 chars when concat is set to 6" do
        ShortMessage.acts_as_sms_options[:allow_concat] = 6
        @short_message = ShortMessage.new(@valid_attributes.merge(:body => "a" * 918))
        @short_message.should be_valid
      end
      it "should allow 919 chars when concat is set to 6" do
        ShortMessage.acts_as_sms_options[:allow_concat] = 6
        @short_message = ShortMessage.new(@valid_attributes.merge(:body => "a" * 919))
        @short_message.should_not be_valid
      end
      it "should allow 160 chars" do
        ShortMessage.acts_as_sms_options[:allow_concat] = 1
        @short_message = ShortMessage.new(@valid_attributes.merge(:body => "a" * 160))
        @short_message.should be_valid
      end
      it "should not allow more then 160 chars" do
        ShortMessage.acts_as_sms_options[:allow_concat] = 1
        @short_message = ShortMessage.new(@valid_attributes.merge(:body => "a" * 161))
        @short_message.should_not be_valid
      end
    end

    describe "orginator_type" do
      it "should not allow blank else as originator type" do
        @short_message = ShortMessage.new(@valid_attributes.merge(:originator_type => ""))
        @short_message.should_not be_valid
      end
      it "should not allow nil else as originator type" do
        @short_message = ShortMessage.new(@valid_attributes)
        @short_message.originator_type = nil
        @short_message.should_not be_valid
      end

      describe "numeric" do
        before(:each) do
          @short_message = ShortMessage.new(@valid_attributes.merge(:originator_type => 'numeric'))
        end
        it "should be valid" do
          @short_message.should be_valid
        end
        it "should allow up to 15 chars" do
          @short_message.should validate_length_of(:originator, :within => 1..15)
        end
        it "should validate format of originator" do
          @short_message.originator = "0046707293274"
          @short_message.should_not be_valid
        end
        it "should be valid format of originator" do
          @short_message.originator = "46707293274"
          @short_message.should be_valid
        end
      end

      describe "shortcode" do
        before(:each) do
          @short_message = ShortMessage.new(@valid_attributes.merge(:originator_type => "shortcode"))
        end
        it "should allow shortcode as originator type" do
          @short_message.should be_valid
        end
        it "should allow up to 15 chars" do
          @short_message.should validate_length_of(:originator, :within => 1..15)
        end
      end

      describe "alpha" do
        before(:each) do
          @short_message = ShortMessage.new(@valid_attributes.merge(:originator_type => "alpha"))
        end
        it "should allow shortcode as originator type" do
          @short_message.should be_valid
        end
        it "should allow up to 11 chars" do
          @short_message.should validate_length_of(:originator, :within => 1..11)
        end
        it "should validate format of originator" do
          @short_message.originator = "Equipe"
          @short_message.should be_valid
        end
        it "should not be valid format of originator" do
          @short_message.originator = "1234567890123"
          @short_message.should_not be_valid
        end
      end
    end

  end

  describe "default settings" do
    before(:each) do
      @short_message = ShortMessage.new
      ShortMessage.acts_as_sms_options[:allow_concat] = 6
    end
    it "should have default settings for type given at setup" do
      @short_message.message_type.should eql('text')
    end
    it "should have default settings for originator type given at setup" do
      @short_message.originator_type.should eql('alpha')
    end
    it "should have default settings for originator given at setup" do
      @short_message.originator.should eql('COMPANYNAME')
    end
    it "should have default setting for allow concat" do
      @short_message.acts_as_sms_options[:allow_concat].should eql(6)
    end
    it "should have max body text length" do
      ShortMessage.acts_as_sms_options[:allow_concat] = 6
      @short_message.max_length.should eql(918) # 6 * 153
    end
    it "should have max body text dependent on allow concat" do
      ShortMessage.acts_as_sms_options[:allow_concat] = 1
      @short_message.max_length.should eql(160)
    end
  end

  describe "configuration file from disk" do

    it "should raise error if configuration file is not found" do
      File.stub!(:exist?).and_return(false)
      lambda {
        ShortMessage.sms_configuration
      }.should raise_error
    end

    it "should load configuration" do
      ShortMessage.instance_eval { @sms_configuration = nil }
      File.stub!(:exist?).and_return(true)
      YAML.should_receive(:load).once.and_return({"sms_url"=>"http://...", "username"=>"user", "password"=>"pass"})
      ShortMessage.sms_configuration
    end

    it "should have instance reader for sms configuration" do
      ShortMessage.new.sms_configuration.should eql(ShortMessage.sms_configuration)
    end

  end

  describe "premimum sms" do

    before(:each) do
      @short_message = ShortMessage.new(@valid_attributes)
      @short_message.class.stub!(:post).and_return("OK: fc444ec93ac7ebdf6a93816a11d23041")
      ShortMessage.stub!(:sms_configuration).and_return(@valid_sms_configuration)
      @short_message.price = 10
    end

    it "should be premium sms" do
      @short_message.should be_premium_sms
    end

    it "should pick the normal sms gateway" do
      @short_message.price = nil
      @short_message.send_sms_url.should eql(@valid_sms_configuration["sms_url"])
    end

    it "should pick the premium sms gateway" do
      @short_message.send_sms_url.should eql(@valid_sms_configuration["psms_url"])
    end

    it "should validate destination as session id" do
      @short_message.destination = "1:1136364712521:0046700123456"
      @short_message.should be_valid
    end
    
    it "should not include destination" do
      @short_message.extract_options_for_sms.should_not have_key(:destination)
    end
    
    it "should not include orginator_type" do
      @short_message.extract_options_for_sms.should_not have_key(:originatortype)
    end
    
    it "should not include orginator" do
      @short_message.extract_options_for_sms.should_not have_key(:originator)
    end
    
    it "should not include allowconcat" do
      @short_message.extract_options_for_sms.should_not have_key(:allowconcat)
    end
    
    it "should not include type" do
      @short_message.extract_options_for_sms.should_not have_key(:type)
    end
    
  end


  describe "send message" do

    before(:each) do
      @short_message = ShortMessage.new(@valid_attributes)
      @short_message.class.stub!(:post).and_return("OK: fc444ec93ac7ebdf6a93816a11d23041")
    end
    
    it "should send a standard sms with less then 160 chars" do
      @short_message.class.should_receive(:post).and_return("OK: fc444ec93ac7ebdf6a93816a11d23041")
      @short_message.send_message
    end

    it "should parse response from premium sms" do
      lambda {
        @short_message.class.stub!(:post).and_return("Ok: 1:1227027450987:0046708569727")
        @short_message.send_message
      }.should_not raise_error
    end    

    it "should create a delivery receipt with response from cellsynt" do
      @short_message.send_message
      @short_message.should have(1).delivery_receipts
    end

    it "should know that the message is sent" do
      @short_message.send_message
      @short_message.should be_sent
    end

    it "should not be sent" do
      @short_message.should_not be_sent
    end

    describe "tracking id" do
      before(:each) do
        @short_message.class.stub!(:post).and_return("OK: fc444ec93ac7ebdf6a93816a11d23041,bc444ec93ac7ebdf6a93816a11d23041")
      end

      it "should save delivery report for each tracking id" do
        @short_message.delivery_receipts.should_receive(:create!).once.with(hash_including(:tracking_id => 'fc444ec93ac7ebdf6a93816a11d23041'))
        @short_message.delivery_receipts.should_receive(:create!).once.with(hash_including(:tracking_id => 'bc444ec93ac7ebdf6a93816a11d23041'))
        @short_message.send_message
      end
    end

    describe "sms status" do
      before(:each) do
        @short_message.class.stub!(:post).and_return("OK: fc444ec93ac7ebdf6a93816a11d23041,bc444ec93ac7ebdf6a93816a11d23041")
        @short_message.send_message
      end

      it "should be delivered" do
        @short_message.delivery_receipts.update_all("status = 'delivered'")
        @short_message.should be_delivered
      end

      it "should be buffered" do
        @short_message.delivery_receipts.first.update_attribute(:status, 'buffered')
        @short_message.should be_buffered
      end

      it "should be be failed" do
        @short_message.delivery_receipts.first.update_attribute(:status, 'failed')
        @short_message.should be_failed
      end

    end

  end

end
