require 'synthesizer/freq/base'

module Synthesizer
  module Freq
    class Fixed < Base
      def initialize(rate)
        @rate = AudioStream::Rate.freq(rate)
      end

      def base_freq(soundinfo, note)
        @rate.freq(soundinfo)
      end
    end
  end
end
