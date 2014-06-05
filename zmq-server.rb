#!/usr/bin/ruby2.0

require_relative 'random_gaussian'
require 'zmq'

zmq = ZMQ::Context.new
socket = zmq.socket(ZMQ::REP)
socket.bind("tcp://*:5555")
while true
  what = socket.recv
  socket.send(what)
end
