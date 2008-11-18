class IncomingShortMessage < ActiveRecord::Base
  alias_attribute :sessionid, :session_id
  
  def self.incoming!(attributes)
    acceptable_attributes = attributes.slice *[column_names, "sessionid"].flatten
    create! acceptable_attributes unless acceptable_attributes.values.all? {|value| value.nil?}
  end
end