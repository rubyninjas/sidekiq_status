require 'mst-status'

DummyApp = Rack::Builder.app do
  use MST::Status

  map '/index' do
    run ->(env) { [200, { 'Content-Type' => 'text/plain' }, 'OK'] }
  end
end
