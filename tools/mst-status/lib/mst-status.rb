require 'mst-status/checker'

if defined? Rails
  class MST::Status::Railtie < Rails::Railtie
    initializer('mst-stats.unshift') do |app|
      app.config.middleware.insert 0, MST::Status
    end
  end
end

module MST
  class Status

    def initialize(app)
      @app = app
    end

    ROUTES = {
      /^\/status$/ => ->(captures) { Checker.get_status },
      /^\/status\/extended$/ => ->(captures) { Checker.get_extended_status },

      /^\/status\/([a-z]*)$/ => ->(captures) do
        module_name = captures.first
        Checker.get_module_status module_name
      end,

      /^\/status\/([a-z]*)\/([a-z]*)$/ => ->(captures) do
        module_name, app_name = captures
        Checker.get_module_app_status module_name, app_name
      end
    }

    MST::Status::Checker.load_default_configuration

    def dispatch path
    end

    def call(env)
      request = Rack::Request.new(env)

      if request.get?
        ROUTES.each do |rule, handler|
          if (match = request.path.match(rule))
            return handler.(match.captures)
          end
        end
      end

      @app.call env
    end
  end
end

Gem.loaded_specs \
  .select { |name, _| name.start_with? 'mst-status-' } \
  .map { |name, _| name.gsub('mst-status-', '') } \
  .each do |plugin_name|
  require "mst-status/modules/#{plugin_name}"
end

