class ShortMessageServiceGenerator < Rails::Generator::Base
  attr_accessor :model, :controller

  def initialize(runtime_args, runtime_options = {})
    super
    puts "runtime_args: #{runtime_args}"
    puts "runtime_options: #{runtime_options}"
  end
  
  def manifest
    record do |m|
    end
  end
end
