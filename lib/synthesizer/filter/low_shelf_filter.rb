module Synthesizer
  module Filter
    class LowShelfFilter
      def initialize(freq:, q: DEFAULT_Q, gain: 1.0)
        @freq = ModulationValue.create(freq)
        @q = ModulationValue.create(q)
        @gain = ModulationValue.create(gain)
      end

      def generator(soundinfo, note_perform, samplecount)
        filter = AudioStream::Fx::LowShelfFilter.new(soundinfo)

        freq_mod = ModulationValue.balance_generator(soundinfo, note_perform, samplecount, @freq)
        q_mod = ModulationValue.balance_generator(soundinfo, note_perform, samplecount, @q)
        gain_mod = ModulationValue.balance_generator(soundinfo, note_perform, samplecount, @gain)

        -> {
          filter.update_coef(freq: freq_mod[], q: q_mod[], gain: gain_mod[])
          filter
        }
      end
    end
  end
end
