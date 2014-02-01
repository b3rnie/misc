#!/usr/bin/ruby2.0
# -*- coding: utf-8 -*-
# Very basic implementation of:
# http://blog.getprismatic.com/blog/2012/10/1/prismatics-graph-at-strange-loop.html
# https://github.com/prismatic/plumbing
#
# Mostly for the sake of learning some Ruby
#
# Bjorn Jensen-Urstad / 2014

class Graph
  def initialize(spec, logger)
    @logger     = logger
    @order      = kahn_sort(spec2edges(spec))
    @operations = spec2operations(spec)
  end

  def run(ctx)
    @order.each{ |op|
      if @operations.has_key?(op) && !ctx.has_key?(op)
        ctx[op] = exec(op, ctx)
      end
    }
    ctx
  end

  private

  def spec2edges(spec)
    edges = []
    spec.each_slice(3) {|label, args, function|
      args.each{ |l|
        edges << [l, label]
      }
    }
    edges.uniq!
    @logger.debug("edges: #{edges}")
    edges
  end

  def spec2operations(spec)
    h = {}
    spec.each_slice(3) { |label, values, function|
      h[label] = [values, function]
    }
    h
  end

  def kahn_sort(edges)
    # source: http://en.wikipedia.org/wiki/Topological_sorting
    #
    # L ← Empty list that will contain the sorted elements#
    # S ← Set of all nodes with no incoming edges
    # while S is non-empty do
    #     remove a node n from S
    #     add n to tail of L
    #     for each node m with an edge e from n to m do
    #         remove edge e from the graph
    #         if m has no other incoming edges then
    #             insert m into S
    # if graph has edges then
    #     return error (graph has at least one cycle)
    # else
    #     return L (a topologically sorted order)
    l = []
    s = start_nodes(nodes(edges), edges)
    while n=s.pop do
      l << n
      edges_tmp, remove = edges.partition{ |e|
        e.first != n
      }
      sn = start_nodes(nodes(edges), edges_tmp)
      edges = edges_tmp
      remove.each{ |e|
        s << e.last if sn.include?(e.last)
      }
    end
    raise("cycle in graph") if edges.length != 0
    @logger.debug("order: #{l}")
    l
  end

  def exec(op, ctx)
    values, func = @operations[op]
    args = values.map{|k|
      raise("missing key #{k} from ctx") unless ctx.has_key?(k)
      ctx[k]
    }
    @logger.debug("executing #{op} with #{args}")
    func.call(*args)
  end

  def nodes(edges)
    nodes = []
    edges.each{ |l|
      nodes << l.first
      nodes << l.last
    }
    nodes.uniq
  end

  def start_nodes(nodes, edges)
    h = edges.inject({}){ |h,e|
      h.store(e.last, 1)
      h
    }
    nodes.select{ |n| !h.has_key?(n)}
  end
end
