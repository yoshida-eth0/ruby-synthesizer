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
  end
end
