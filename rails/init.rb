require 'equipe'
ActiveRecord::Base.send(:include, Equipe::ActsAsSms)
Rails.logger.info "* acts_as_sms initialized"