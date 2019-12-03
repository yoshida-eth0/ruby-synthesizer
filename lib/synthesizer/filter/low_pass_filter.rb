module Synthesizer
  module Filter
    class LowPassFilter
      def initialize(freq:, q: DEFAULT_Q)
        @freq = ModulationValue.create(freq)
        @q = ModulationValue.create(q)
      end

      def generator(note_perform, samplecount)
        soundinfo = note_perform.synth.soundinfo
        filter = AudioStream::Fx::LowPassFilter.new(soundinfo)

        freq_mod = ModulationValue.balance_generator(note_perform, samplecount, @freq)
        q_mod = ModulationValue.balance_generator(note_perform, samplecount, @q)

        -> {
          filter.update_coef(freq: freq_mod[], q: q_mod[])
          filter
        }
      end
    end
  end
end
