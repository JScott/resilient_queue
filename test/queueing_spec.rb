require 'bundler/setup'
require 'resilient_queue'

context 'queueing' do
  setup do
    @timeout = 1
    @queue = ResilientQueue.new name: 'test', timeout: @timeout
    @queue.db.clear
    @item = 'test_item'
  end

  should 'add and remove items' do
    assert_equal 1, @queue.enqueue(@item)
    assert_equal @item, @queue.dequeue
  end

  should 'requeue items that don\'t finish' do
    assert_equal 1, @queue.enqueue(@item)
    @queue.dequeue
    sleep (@timeout+1)
    assert_equal 2, @queue.enqueue(@item)
  end
end
