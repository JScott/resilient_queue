require 'kintama'
require 'moneta'
require 'daybreak'
require 'redislike'

class ResilientQueue
  attr_reader :db
  def initialize(options = {})
    @name = options.fetch :name, 'default'
    @timeout = options.fetch :timeout, 60
    @db = Moneta.new :Daybreak, expires: true, file: ".#{@name}.db"
  end

  def key_for(type, with_id: 0)
    key = case type
    when :pending_list
      "#{@name}:pending"
    when :claimed_list
      "#{@name}:claimed"
    when :claimed_flag
      "#{@name}:task:#{with_id}:claimed"
    when :item_store
      "#{@name}:@{id}"
    when :id_count
      "#{@name}:id_count"
    else
    end
    "#{@name}:#{key}"
  end

  def create_id
    @db.increment key_for(:id_count)
  end

  def lookup(id)
    @db.fetch key_for(:item_store, with_id: id), nil
  end

  def enqueue(item)
    id = create_id
    @db.store key_for(:item_store, with_id: id), item
    @db.lpush key_for(:pending_list), id
  end

  def dequeue
    process_expired_claims
    id = @db.rpoplpush key_for(:pending_list), key_for(:claimed_list)
    @db.store key_for(:claimed_flag, with_id: id), true, expires: @timeout
    id
  end

  def process_expired_claims
  end
end
