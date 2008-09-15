config.gem "httparty"
config.after_initialize do
  ActiveRecord::Base.send(:include, Equipe::ActsAsSms)
end
