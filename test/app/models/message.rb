class Message < ActiveRecord::Base
  acts_as_sms :message_type => 'text',
    :originator_type => 'alpha',
    :originator => 'Equipe'
end
