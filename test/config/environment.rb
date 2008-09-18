RAILS_GEM_VERSION = '2.1.0' unless defined? RAILS_GEM_VERSION

require File.join(File.dirname(__FILE__), 'boot')

class NoneRecursiveFileSystemLocator < Rails::Plugin::FileSystemLocator
  private
  def locate_plugins_under(base_path)
    Dir.glob(File.join(base_path, '*')).inject([]) do |plugins, path|
      if plugin = create_plugin(path)
        plugins << plugin
      end
      plugins
    end
  end
end

Rails::Initializer.run do |config|
  config.load_paths += ['../lib'] 
  config.plugin_paths = ['vendor/plugins', "#{Rails.root}/.."]
  config.plugin_locators = [NoneRecursiveFileSystemLocator]
  config.reload_plugins = true
  config.time_zone = 'UTC'
  config.action_controller.session = {
    :session_key => '_test_session',
    :secret      => '1fa781c6f23c0ffb5eb5c86b72c090196d28e77a3fc16cf35186f423f7b3598da64d1fc4d4270cd9a92b13412610f8d7477b09d3045b386a2d4f39fb96fe571e'
  }
end
