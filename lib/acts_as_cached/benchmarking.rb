require 'benchmark'

module ActsAsCached
  module Benchmarking #:nodoc:
    def self.cache_runtime
      @@cache_runtime ||= 0.0
    end

    def self.cache_reset_runtime
      @@cache_runtime = nil
    end

    def self.cache_benchmark(event)
      return yield unless Rails.logger

      @@cache_runtime ||= 0.0
      @@cache_runtime += event.duration

      Rails.logger.debug("==> #{event.name} (#{'%.1f' % event.duration})")
    end
  end
end

module ActsAsCached
  module MemcacheRuntime
    extend ActiveSupport::Concern
    protected

    def append_info_to_payload(payload)
      super
      payload[:memcache_runtime] = ActsAsCached::Benchmarking.cache_runtime
      ActsAsCached::Benchmarking.cache_reset_runtime
    end

    module ClassMethods
      def log_process_action(payload)
        messages, memcache_runtime = super, payload[:memcache_runtime]
        messages << ("Memcache: %.1fms" % memcache_runtime.to_f) if memcache_runtime
        messages
      end
    end
  end
end


ActiveSupport::Notifications.subscribe /cache/ do |*args|
  event =  ActiveSupport::Notifications::Event.new(*args)
  ActsAsCached::Benchmarking.cache_benchmark(event)
end

ActionController::Base.include ActsAsCached::MemcacheRuntime
