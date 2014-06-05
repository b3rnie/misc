#!/usr/bin/ruby2.0

class RandomGaussian
  def initialize(rand_helper = lambda { Kernel.rand })
    @rand_helper = rand_helper
  end

  def rand
    begin
      y1,y2 = gaussian
    end until y1 >= -3 && y1 <= 3
    (y1 + 3) / 6
  end

  private
  def gaussian
    begin
      x1 = 2.0 * @rand_helper.call - 1.0
      x2 = 2.0 * @rand_helper.call - 1.0
      w  = x1 * x1 + x2 * x2
    end until w < 1.0
    w = Math.sqrt((-2.0 * Math.log(w)) / w)
    y1 = x1 * w
    y2 = x2 * w
    return y1, y2
  end
end
