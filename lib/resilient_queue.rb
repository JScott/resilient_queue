require 'kintama'
require 'moneta'
require 'daybreak'
require 'redislike'

class ResilientQueue
  attr_reader :db
  def initialize(options = {})
    name = options.fetch :name, 'default'
    timeout = options.fetch :timeout, 60
    @pending = "#{name}:pending"
    @claimed = "#{name}:claimed"
    @db = Moneta.new :Daybreak, expires: true, file: ".#{name}.db"
  end

  def enqueue(item)
    @db.lpush @pending, item
  end

  def dequeue
    @db.rpoplpush @pending, @claimed
  end
end
