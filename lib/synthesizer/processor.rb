require 'synthesizer/processor/low'
require 'synthesizer/processor/high'

module Synthesizer
  module Processor
    def self.create(quality)
      const_get(quality, false).new
    end
  end
end
