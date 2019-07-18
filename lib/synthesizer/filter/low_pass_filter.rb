module Synthesizer
  module Filter
    class LowPassFilter
      def initialize(freq:, q: nil)
        @freq = ModulationValue.create(freq)
        @q = ModulationValue.create(q || 1.0 / Math.sqrt(2))
      end

      def generator(note_perform, framerate, &block)
        Enumerator.new do |y|
          soundinfo = note_perform.synth.soundinfo
          filter = AudioStream::Fx::LowPassFilter.new(soundinfo)

          freq_mod = ModulationValue.balance_generator(note_perform, framerate, @freq)
          q_mod = ModulationValue.balance_generator(note_perform, framerate, @q)

          loop {
            filter.update_coef(freq: freq_mod.next, q: q_mod.next)
            y << filter
          }
        end.each(&block)
      end
    end
  end
end
