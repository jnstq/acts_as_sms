require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DeliveryReceiptsController do

  describe "GET 'update'" do
    
    it "should update status 'delivered'" do
      delivery_receipt = DeliveryReceipt.new
      delivery_receipt.stub!(:save)
      DeliveryReceipt.stub!(:find_by_tracking_id).and_return(delivery_receipt)
      get :report, :trackingid => "fc444ec93ac7ebdf6a93816a11d23041", :status => 'delivered', :destination => '0046707293123'
      delivery_receipt.status.should eql("delivered")
    end
    
  end
  
end
