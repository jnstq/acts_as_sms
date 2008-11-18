class <%=delivery_receipt_model_name.pluralize%>Controller < ApplicationController
  
  def report
    @<%= delivery_receipt_model_name.underscore %> = <%=delivery_receipt_model_name%>.find_by_tracking_id(params[:trackingid])
    @<%= delivery_receipt_model_name.underscore %>.status = params[:status]
    @<%= delivery_receipt_model_name.underscore %>.save
    head :ok
  end

end
