class <%= delivery_receipt_model_name %> < ActiveRecord::Base
  belongs_to :short_message<%= ", :class_name => '#{short_message_model_name}'" unless standard_short_message_model_name? %>
end