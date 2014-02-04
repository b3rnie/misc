#!/usr/bin/ruby2.0
require_relative "graph"
require 'logger'
require 'test/unit'

class TestGraph < Test::Unit::TestCase
  def test_basic
    g = Graph.new([:n,  [:xs],      lambda { |xs| xs.length },
                   :m,  [:xs, :n],  lambda { |xs, n| xs.inject{|sum,x| sum + x } / n},
                   :m2, [:xs, :n],  lambda { |xs, n| xs.inject{|sum,x| sum + (x*x) }.to_f / n},
                   :v,  [:m,  :m2], lambda { |m, m2| m2 - m*m}],
                  Logger.new(STDOUT))
    res = g.run(:xs => [1, 2, 3, 6])
    assert_equal(4,    res[:n])
    assert_equal(3,    res[:m])
    assert_equal(12.5, res[:m2])
    assert_equal(3.5,  res[:v])
  end

  def test_missing_input
    g = Graph.new([:y, [:x], lambda { |x| x*x }], Logger.new(STDOUT))
    assert_raise(KeyError) { g.run(:z => 1) }
  end

  def test_cycle
    e = assert_raise(RuntimeError) {
      g = Graph.new([:y, [:x], lambda{ |x| x },
                     :z, [:y], lambda{ |y| y },
                     :x, [:z], lambda{ |z| z }], Logger.new(STDOUT))
    }
    assert_equal("cycle in graph", e.message)
  end
end
