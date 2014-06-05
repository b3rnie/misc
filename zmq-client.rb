#!/usr/bin/ruby2.0

require_relative 'random_gaussian'
require 'zmq'

zmq = ZMQ::Context.new
socket = zmq.socket(ZMQ::REQ)
socket.connect("tcp://localhost:5555")

while true
  msg = Random.rand(100)
  raise "send error" unless socket.send(msg.to_s)
  if ZMQ.select([socket], nil, nil, 5)
    rep = socket.recv
    puts msg.to_s + "  " + rep.to_s
    raise msg.to_s + " - " + rep.to_s unless rep.to_s == msg.to_s
  else
    socket.close
    raise("timeout")
  end
end

