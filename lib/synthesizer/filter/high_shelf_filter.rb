module Synthesizer
  module Filter
    class HighShelfFilter
      def initialize(freq:, q: DEFAULT_Q, gain: 1.0)
        @freq = ModulationValue.create(freq)
        @q = ModulationValue.create(q)
        @gain = ModulationValue.create(gain)
      end

      def generator(note_perform, framerate, &block)
        Enumerator.new do |y|
          soundinfo = note_perform.synth.soundinfo
          filter = AudioStream::Fx::HighShelfFilter.new(soundinfo)

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
