class ShortMessage < ActiveRecord::Base
  acts_as_sms :originator => 'COMPANYNAME'
end