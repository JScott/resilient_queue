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

  def create_id
    @db.increment "#{@name}:id_count"
  end

  def lookup(id)
    @db.fetch Key.item(id), nil
  end

  def claims
    @db.fetch Key.list(:claimed), []
  end

  def recent_claim?(id)
    @db.fetch Key.flag(:claimed, id), false
  end

  def finished?(id)
    @db.fetch Key.flag(:finished, id), false
  end

  def remove_claim_on(id)
    @db.lrem Key.list(:claimed), 0, id
    @db.delete Key.flag(:claimed, id)
  end

  def enqueue(item)
    process_expired_claims
    id = create_id
    @db.store Key.item(id), item
    @db.lpush Key.list(:pending), id
  end

  def dequeue
    process_expired_claims
    id = @db.rpoplpush Key.list(:pending), Key.list(:claimed)
    @db.store Key.flag(:claimed, id), true, expires: @timeout
    id
  end

  def requeue(id)
    @db.lpush Key.list(:pending), id
  end

  def finish(id)
    @db.store Key.flag(:finished, id), true
  end

  def process_expired_claims
    claims.each do |id|
      next if recent_claim? id
      remove_claim_on id
      requeue id unless finished? id
    end
  end
end
