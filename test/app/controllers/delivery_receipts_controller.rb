class DeliveryReceiptsController < ApplicationController
  
  def report
    @delivery_receipt = DeliveryReceipt.find_by_tracking_id(params[:trackingid])
    @delivery_receipt.status = params[:status]
    @delivery_receipt.save
  end

end
