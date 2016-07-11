$LOAD_PATH << File.join(__dir__, 'lib')

require 'sidekiq'
require 'thin'
require 'mst-status'

Thin::Logging.silent = true

# Disable rack logger
module Rack
  class CommonLogger
    def call(env)
      @app.call(env)
    end
  end
end

MST::Status::Checker.load_configuration File.join(__dir__, 'config.json')

require 'app_controller'

use MST::Status
run Sinatra::Application
