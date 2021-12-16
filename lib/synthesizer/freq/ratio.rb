require 'synthesizer/freq/base'

module Synthesizer
  module Freq
    class Ratio < Base
      def initialize(ratio)
        @ratio = ratio
      end

      def base_freq(soundinfo, note)
        note.freq * @ratio
      end
    end
  end
end
