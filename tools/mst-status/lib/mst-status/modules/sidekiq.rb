require 'mst-status/checker'
require 'mst-status/modules/sidekiq/sidekiq_watcher'
require 'json'

module MST
  module Modules
    class Sidekiq

      def initialize config
        unless config['environment'] == 'test'
          ::Sidekiq.instance_variable_set(:@redis, nil)
          ::Sidekiq.configure_client do |c|
            c.redis = { :url => config['url'], :namespace => config['namespace'] }
          end
        end

        @watchers = { 
          'worker' => MST::SidekiqWatcher.new('worker', config)
        }
      end
      
      def status
        to_status(@watchers.all? { |_, w| w.fetch_alive_status! })
      end

      def app_status app_name
        watcher = @watchers[app_name.to_s]
        to_status(watcher && watcher.fetch_alive_status!)
      end

      def extended_status
        @watchers.inject({}) do |c, (name, _)|
          c[name] = app_status name
          c
        end
      end

      private

      def to_status res
        res ? :OK : :Fail
      end

    end
  end
end

MST::Status::Checker.register_module_class 'sidekiq', MST::Modules::Sidekiq
