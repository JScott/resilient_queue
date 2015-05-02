require 'moneta'
require 'daybreak'
require 'redislike'

class ResilientQueue
  attr_reader :db
  def initialize(options = {})
    @namespace = options.fetch 'namespace', 'default'
    @queue = "#{@namespace}:#{options.fetch 'queue', 'tasks'}"
    fail ArgumentError, 'queue should be plural' unless @queue.end_with? 's'
    @item = @queue[0, -2] # Singular form of queue name.
    backend = options.fetch 'backend', :Daybreak
    @db = Moneta.new backend, expires: true, file: ".#{@namespace}.db"
  end

  def disconnect
    @db.close
  end

  def claim(expires_in: 10)
    id = @db.rpoplpush "#{@queue}:pending", "#{@queue}:claimed"
    @db.store "#{@item}:#{id}:claimed", true, expires: expires_in
    id

    # Concurrent.atomically do
    #   pending = @db.fetch "#{@queue}:pending", []
    #   claimed = @db.fetch "#{@queue}:claimed", []
    #   id = pending.shift
    #   claimed.push id
    #   @db.store "#{@queue}:pending", pending
    #   @db.store "#{@queue}:claimed", claimed
    #   @db.store "#{@item}:#{id}:claimed", true, expires: expires_in
    # end
  end

  def claimed?(id)
    @db.key? "#{@item}:#{id}:claimed"
  end

  def claims
    @db.fetch "#{@queue}:claimed", []
  end

  def purge_claims(id)
    expire_claim id
    @db.lrem "#{@queue}:claimed", 0, id

    # expire_claim id
    # Concurrent.atomically do
    #   claimed = @db.fetch "#{@queue}:claimed", []
    #   claimed.delete id
    #   @db.store "#{@queue}:claimed", claimed
    # end
  end

  def expire_claim(id)
    @db.delete "#{@item}:#{id}:claimed"
  end

  def requeue(id)
    @db.lpush "#{@queue}:pending", id

    # Concurrent.atomically do
    #   pending = @db.fetch "#{@queue}:pending", []
    #   pending.push id
    #   @db.store "#{@queue}:pending", pending
    # end
  end

  def details(id)
    @db.fetch "#{@item}:#{id}", {}
  end

  def succeeded?(_id)
    false
  end

  def failed?(_id)
    false
  end

  def done?(id)
    succeeded?(id) || failed?(id)
  end
end

