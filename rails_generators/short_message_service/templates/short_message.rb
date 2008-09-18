class <%= short_message_model_name %> < ActiveRecord::Base
  acts_as_sms :originator => 'COMPANYNAME'<%= ", :delivery_receipt_class_name => '#{delivery_receipt_model_name}'" unless standard_delivery_receipt_model_name? %>
end