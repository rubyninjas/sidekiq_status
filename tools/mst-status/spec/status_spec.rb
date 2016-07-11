require 'spec_helper'
require 'oj'

describe MST::Status do
  include Rack::Test::Methods

  let(:app) { DummyApp }

  shared_examples 'status_endpoint' do

     it 'responds with 200 status' do
      expect(last_response.status).to eq(200)
    end

    it 'returns status FAIL' do
      expect(Oj.load(last_response.body)['status']).to eq('Fail')
    end

  end

  describe 'GET /status' do
    before { get '/status' }

     it_should_behave_like 'status_endpoint'
  end

end
