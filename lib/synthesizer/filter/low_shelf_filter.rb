module Synthesizer
  module Filter
    class LowShelfFilter
      def initialize(freq:, q: nil, gain:)
        @freq = ModulationValue.create(freq)
        @q = ModulationValue.create(q || 1.0 / Math.sqrt(2))
        @gain = ModulationValue.create(gain)
      end

      def generator(note_perform, framerate, &block)
        Enumerator.new do |y|
          soundinfo = note_perform.synth.soundinfo
          filter = AudioStream::Fx::LowShelfFilter.new(soundinfo)

          freq_mod = ModulationValue.balance_generator(note_perform, framerate, @freq)
          q_mod = ModulationValue.balance_generator(note_perform, framerate, @q)
          gain_mod = ModulationValue.balance_generator(note_perform, framerate, @gain)

          loop {
            filter.update_coef(freq: freq_mod.next, q: q_mod.next, gain: gain_mod.next)
            y << filter
          }
        end.each(&block)
      end
    end
  end
end
