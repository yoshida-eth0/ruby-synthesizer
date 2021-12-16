require 'synthesizer/freq/base'
require 'synthesizer/freq/fixed'
require 'synthesizer/freq/ratio'
require 'synthesizer/freq/thru'

module Synthesizer
  module Freq
    def self.fixed(rate)
      Fixed.new(rate)
    end

    def self.ratio(ratio)
      Ratio.new(ratio)
    end

    def self.thru
      Thru.instance
    end
  end
end
