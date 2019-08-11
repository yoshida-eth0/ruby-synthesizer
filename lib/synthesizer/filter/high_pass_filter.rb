module Synthesizer
  module Filter
    class HighPassFilter
      def initialize(freq:, q: DEFAULT_Q)
        @freq = ModulationValue.create(freq)
        @q = ModulationValue.create(q)
      end

      def generator(note_perform, framerate, &block)
        Enumerator.new do |y|
          soundinfo = note_perform.synth.soundinfo
          filter = AudioStream::Fx::HighPassFilter.new(soundinfo)

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
