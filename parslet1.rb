#!/usr/bin/ruby2.0

require 'parslet'

class BParser < Parslet::Parser
  root(:list)
  rule(:list) {
    (soc? >>
     str('TRANSACTION') >> space >> soc? >>
     account.repeat.as(:transaction)
     ).repeat
  }

  rule(:account) {
    soc? >>
    match('[0-9]').repeat(4).as(:no) >> space >>
    ((str('+') | str('-')).maybe >>
     match('[0-9]').repeat()).as(:amount) >> space
  }

  rule(:soc)      { (space | comment).repeat }
  rule(:soc?)     { soc.maybe }

  rule(:comment)  { str('#') >> match('[^\n]').repeat }
  rule(:comment?) { comment.maybe }

  rule(:space)    { match('\s').repeat(1) }
  rule(:space?)   { space.maybe }
end

class BTransform < Parslet::Transform
  rule(:transaction => subtree(:x)) {
    x.map{ |e|
      {:no => e[:no].to_i, :amount => e[:amount].to_i}
    }
  }
end

def parse(str)
  tree = BParser.new.parse(str)
  puts tree
  puts ''
  puts BTransform.new.apply(tree)
rescue Parslet::ParseFailed => failure
  puts failure.cause.ascii_tree
end



s =
"TRANSACTION #mmm
# foo
5510 +100
1910 -200

TRANSACTION

3000 123
5000 879
"

parse(s)

