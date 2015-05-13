require 'moneta'
require 'daybreak'
require 'redislike'

class StubbornQueue
  attr_reader :db
  def initialize(options = {})
    @name = options.fetch :name, 'default'
    @timeout = options.fetch :timeout, 60
    path = options.fetch :file, ".#{@name}.db"
    @db = Moneta.new :Daybreak, expires: true, file: path
  end

  module Key
    def self.list(name)
      "#{@name}:#{name}"
    end

    def self.flag(type, id)
      "#{@name}:task:#{id}:#{type}"
    end

    def self.item(id)
      "#{@name}:#{id}"
    end
  end

  def key_for(type, with_id: 0)
    key = case type
    when :pending_list
      "#{@name}:pending"
    when :claimed_list
      "#{@name}:claimed"
    when :claimed_flag
      "#{@name}:task:#{with_id}:claimed"
    when :finished_flag
      "#{@name}:task:#{with_id}:finished"
    when :item_store
      "#{@name}:@{id}"
    when :id_count
      "#{@name}:id_count"
    else
      fail "Key for '#{type}' is unrecognized."
    end
    "#{@name}:#{key}"
  end

  def create_id
    @db.increment key_for(:id_count)
  end

  def lookup(id)
    @db.fetch key_for(:item_store, with_id: id), nil
  end

  def claims
    @db.fetch Key::list(:claimed), []
  end

  def recent_claim?(id)
    @db.fetch key_for(:claimed_flag, with_id: id), false
  end

  def finished?(id)
    @db.fetch key_for(:finished_flag, with_id: id), false
  end

  def remove_claim_on(id)
    @db.lrem Key::list(:claimed), 0, id
    @db.delete key_for(:claimed_flag, with_id: id)
  end

  def enqueue(item)
    process_expired_claims
    id = create_id
    @db.store key_for(:item_store, with_id: id), item
    @db.lpush Key::list(:pending), id
  end

  def dequeue
    process_expired_claims
    id = @db.rpoplpush Key::list(:pending), Key::list(:claimed)
    @db.store key_for(:claimed_flag, with_id: id), true, expires: @timeout
    id
  end

  def requeue(id)
    @db.lpush Key::list(:pending), id
  end

  def finish(id)
    @db.store key_for(:finished_flag, with_id: id), true
  end

  def process_expired_claims
    claims.each do |id|
      next if recent_claim? id
      remove_claim_on id
      requeue id unless finished? id
    end
  end
end
