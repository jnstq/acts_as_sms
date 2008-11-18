class IncomingShortMessage < ActiveRecord::Base
  alias_attribute :sessionid, :session_id
  
  def self.incoming!(attributes)
    valid_attributes = attributes.slice *[column_names, "sessionid"].flatten
    create! valid_attributes unless valid_attributes.values.all? {|value| value.nil?}
  end
end

