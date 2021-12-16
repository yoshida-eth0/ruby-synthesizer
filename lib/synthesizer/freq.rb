module Synthesizer
  module Freq
    class Base
      def note_num(soundinfo, note)
        f = base_freq(soundinfo, note)
        Math.log2(f / 6.875) * 12 - 3
      end

      def freq(soundinfo, note, semis: 0, cents: 0)
        num = note_num(soundinfo, note)
        freq = 6.875 * (2 ** ((num + semis + (cents / 100.0) + 3) / 12.0))
        AudioStream::Rate.freq(freq)
      end
    end

    class Fixed < Base
      def initialize(rate)
        @rate = AudioStream::Rate.freq(rate)
      end

      def base_freq(soundinfo, note)
        @rate.freq(soundinfo)
      end
    end

    class Ratio < Base
      def initialize(ratio)
        @ratio = ratio
      end

      def base_freq(soundinfo, note)
        note.freq * @ratio
      end
    end

    def self.fixed(rate)
      Fixed.new(rate)
    end

    def self.ratio(ratio)
      Ratio.new(ratio)
    end

    DEFAULT = Ratio.new(1.0)
  end
end
