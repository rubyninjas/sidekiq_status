require 'sidekiq'
require 'sidekiq/api'
require 'redis'

require 'yaml'
require 'timeout'

module MST
  class SidekiqWatcher

    def fetch_alive_status!

      alive = true    
      begin
        collect_stats!

        unless is_first_run? or sidekiq_is_working?
          minutes_passed = minutes_diff Time.now, @last_update
          alive = false if minutes_passed > @config['timeout']
        end

        # TODO track state on internal timer event
        track_state!

      rescue Timeout::Error, Redis::TimeoutError, 
             Redis::CannotConnectError, Redis::ConnectionError
        alive = false
      end
      alive 
    end

    def initialize app_name, config
      @config = config
      @app_name = app_name
    end


    protected

    def collect_stats!
      concerned_queues = ->(name, _)  { @config["#{@app_name}_queues"].include? name }
      stats = Sidekiq::Stats.new
      Timeout.timeout(5) do
        @enqueued = stats.queues.select(&concerned_queues).values.inject(:+)
        @processed = stats.processed
      end
    end

    def track_state!
      if is_first_run? or queues_are_empty? or sidekiq_is_working?
        @last_update = Time.now  
      end
      @last_processed = @processed
    end

    def queues_are_empty?
      @enqueued == 0
    end

    def is_first_run?
      @last_processed.nil? or @last_update.nil?
    end

    def sidekiq_is_working?
      @enqueued != 0 and @last_processed != @processed
    end
    
    def minutes_diff start_time, end_time
      seconds_diff = (start_time - end_time).to_i.abs
      seconds_diff / 60
    end
  end

end

