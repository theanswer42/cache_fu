require 'cache_fu'
require 'rails'

module ActsAsCached
  class Railtie < Rails::Railtie
    initializer 'cache_fu.extends' do
      ActiveSupport.on_load :active_record do
        extend ActsAsCached::Mixin
      end

      if File.exists?(config_file = Rails.root.join('config', 'memcached.yml'))
        ActsAsCached.config = YAML.load(ERB.new(IO.read(config_file)).result)
      else
        ActsAsCached.config = {}
      end

      ActiveSupport.on_load :action_controller do
        include ActsAsCached::MemcacheRuntime
      end
    end
  end
end
