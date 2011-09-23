require 'cache_fu'
require 'rails'

module ActsAsCached
  class Railtie < Rails::Railtie
    initializer 'cache_fu.extends' do
      ActiveSupport.on_load :active_record do
        extend ActsAsCached::Mixin
      end

      ActiveSupport.on_load :action_controller do
        include ActsAsCached::MemcacheRuntime
      end
    end

    rake_tasks do
      load 'tasks/memcached.rake'
    end
  end
end
