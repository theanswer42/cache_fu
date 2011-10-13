require File.dirname(__FILE__) + '/acts_as_cached/cache_methods'
require File.dirname(__FILE__) + '/acts_as_cached/benchmarking'
require File.dirname(__FILE__) + '/acts_as_cached/railtie' if defined?(Rails)

module ActsAsCached
  @@config = {}
  mattr_reader :config

  def self.config=(options)
    @@config = options
  end

  def self.skip_cache_gets=(boolean)
    ActsAsCached.config[:skip_gets] = boolean
  end

  def self.valued_keys
    [:version, :pages, :per_page, :finder, :cache_id, :find_by, :key_size]
  end

  module Mixin
    def acts_as_cached(options = {})
      extend  ClassMethods
      include InstanceMethods

      options.symbolize_keys!

      # convert the find_by shorthand
      if find_by = options.delete(:find_by)
        options[:finder]   = "find_by_#{find_by}".to_sym
        options[:cache_id] = find_by
      end

      cache_config.replace  options.reject { |key,| not ActsAsCached.valued_keys.include? key }
      cache_options.replace options.reject { |key,| ActsAsCached.valued_keys.include? key }
    end
  end
end

Rails::Application.initializer("cache_fu") do
  if File.exists?(config_file = Rails.root.join('config', 'memcached.yml'))
    ActsAsCached.config = YAML.load(ERB.new(IO.read(config_file)).result)
  end
  ActsAsCached.config = {}
end
