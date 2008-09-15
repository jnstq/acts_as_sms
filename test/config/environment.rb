RAILS_GEM_VERSION = '2.1.0' unless defined? RAILS_GEM_VERSION

require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.plugin_paths += ['vendor/plugins', "#{Rails.root}/../.."]
  # config.reload_plugins = true
  config.time_zone = 'UTC'
  config.action_controller.session = {
    :session_key => '_test_session',
    :secret      => '1fa781c6f23c0ffb5eb5c86b72c090196d28e77a3fc16cf35186f423f7b3598da64d1fc4d4270cd9a92b13412610f8d7477b09d3045b386a2d4f39fb96fe571e'
  }
end