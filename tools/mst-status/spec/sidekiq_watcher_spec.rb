require 'spec_helper'
require 'mst-status/modules/sidekiq/sidekiq_watcher'

QUEUE_NAME = 'test_queue'
TIMEOUT_MINUTES = 5

describe MST::SidekiqWatcher do

  def setup_queue params
    allow_any_instance_of(::Sidekiq::Stats).to receive_messages(
      :queues => {QUEUE_NAME => params[:enqueued]}, :processed => params[:processed])
  end

  def create_watcher params = {}
     MST::SidekiqWatcher.new 'worker', 'worker_queues' => [ QUEUE_NAME ], 'timeout' => params[:timeout] || TIMEOUT_MINUTES
  end

  def create_time_point minutes
    Time.new(2000,1,1,1,minutes,0, "+09:00") 
  end
  
  context 'with an empty queue' do

    before(:each) do
      setup_queue :enqueued =>0, :processed => 0
      @watcher = create_watcher
    end

    it 'returns -is alive-' do
       expect(@watcher.fetch_alive_status!).to eq(true)
    end

    it 'returns -is alive- on second call too' do
       2.times { expect(@watcher.fetch_alive_status!).to eq(true) }
    end
  end

  context 'queue contains messages' do

    def set_time_now minutes
      allow(Time).to receive_messages(:now => create_time_point(minutes) )
    end
    
    def init_timeline 
      set_time_now 0
    end

    def move_timeline_by minutes
      set_time_now minutes
    end
    
    before(:each) do
      setup_queue :enqueued =>100, :processed => 30
      @watcher = create_watcher
    end

    it 'waits for timeout if sidekiq has got stuck' do
      init_timeline
      2.times { @watcher.fetch_alive_status! }
      move_timeline_by(TIMEOUT_MINUTES + 1)
      expect(@watcher.fetch_alive_status!).to eq(false) 
    end

    it 'recovers on sidekiq start' do
      
    end

  end
end    

