#!/usr/bin/ruby2.0

require 'redis'
require 'pp'

r = Redis.new(:host => 'localhost', :port => 6379)
r.flushall

r.set("foo", "bar")
pp r.get("foo")
pp r.exists("foo")
pp r.type("foo")
r.append("foo", "bar")
r.rename("foo", "bar")
r.expire("bar", 10)
pp r.get("bar")
r.del("bar")

puts("HASHES")
r.hset("hash0", "k", "v")
r.hset("hash0", "kk", "vv")
pp r.hvals("hash0")
pp r.hkeys("hash0")
pp r.hget("hash0", "k")
r.hdel("hash0", "k")

puts("LISTS..")
pp r.rpush("list", "foo")
pp r.rpush("list", "bar")
pp r.llen("list")
r.rpush("list1", "1.44")
r.rpush("list1", "2.1")
pp r.sort("list1")

puts("SETS")
r.sadd("set0", ["m1", "m2", "m3"])
r.sadd("set0", "m4")
r.srem("set0", "m2")
pp r.scard("set0")
pp r.smembers("set0")

pp("TRANSACTIONS")
x = r.multi do
  r.set("foo", "bar")
  r.set("baz", "buz")
end
pp x

puts("SORTED SETS")
# sorted sets
r.zadd("sset0", 5, "foo")
r.zadd("sset0", 3, "bar")
r.zadd("sset0", 7, "baz")
r.zadd("sset0", 9, "buz")

pp r.zrange("sset0", 0, 1)
pp r.zrevrange("sset0", 0, 2)

(1..1000).each do |i|
  r.zadd("sset1", Random.rand(0xFFFF), i)
end

pp r.zrangebyscore("sset1", 0, 0xFF)

puts("PUBSUB")
t = Thread.new do
  r2 = Redis.new(:host => 'localhost', :port => 6379, :timeout => 0)
  r2.subscribe("pubsub0") do |sub|
    sub.message do |channel, msg|
      pp "channel #{channel}"
      pp "message #{msg}"
      Thread.exit if msg == "exit"
    end
  end
end
sleep 1

r.publish("pubsub0", "bar")
r.publish("pubsub0", "foo")
r.publish("pubsub0", "exit")
t.join

r.flushall
