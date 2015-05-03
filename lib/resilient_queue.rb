require 'kintama'
require 'moneta'
require 'daybreak'
require 'redislike'

class ResilientQueue
  attr_reader :db
  def initialize(options = {})
    @name = options.fetch :name, 'default'
    @timeout = options.fetch :timeout, 60
    @pending = "#{@name}:pending"
    @claimed = "#{@name}:claimed"
    @db = Moneta.new :Daybreak, expires: true, file: ".#{@name}.db"
  end

  def create_id
    @db.increment "#{@name}:id_count"
  end

  def enqueue(item)
    id = create_id
    @db.store "#{@name}:#{id}", item, expires: @timeout
    @db.lpush @pending, id
  end

  def dequeue
    # TODO: requeuing
    id = @db.rpoplpush @pending, @claimed
    @db.fetch "#{@name}:#{id}"
  end
end
