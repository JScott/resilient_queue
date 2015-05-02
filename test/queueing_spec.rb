require 'bundler/spec'
require 'resilient_queue'

context 'queueing' do
  setup do
    @timeout = 2
    @queue = ResilientQueue.new namespace: 'test', timeout: @timeout
    @item = 'test_item'
  end

  should 'add and remove items' do
    @queue.enqueue @item
    assert_equal @queue.size, 1
    assert_equal @item, @queue.dequeue
  end

  should 'requeue items that don\'t finish' do
    @queue.enqueue @item
    @queue.dequeue
    assert_equal @queue.size, 0
    sleep (@timeout+1)
    assert_equal @queue.size, 1
  end
end
