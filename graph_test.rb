#!/usr/bin/ruby2.0
require_relative "graph"
require 'test/unit'

class TestGraph < Test::Unit::TestCase
  def test_basic
    g = Graph.new([:n,  [:xs],      lambda { |xs| xs.length },
                   :m,  [:xs, :n],  lambda { |xs, n| xs.inject{|sum,x| sum + x } / n},
                   :m2, [:xs, :n],  lambda { |xs, n| xs.inject{|sum,x| sum + (x*x) }.to_f / n},
                   :v,  [:m,  :m2], lambda { |m, m2| m2 - m*m}])
    res = g.run(:xs => [1, 2, 3, 6])
    assert_equal(4,    res[:n])
    assert_equal(3,    res[:m])
    assert_equal(12.5, res[:m2])
    assert_equal(3.5,  res[:v])
  end
end

