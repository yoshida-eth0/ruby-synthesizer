module Synthesizer
  module Filter
    class HighShelfFilter
      def initialize(freq:, q: DEFAULT_Q, gain: 1.0)
        @freq = ModulationValue.create(freq)
        @q = ModulationValue.create(q)
        @gain = ModulationValue.create(gain)
      end

      def generator(note_perform, framerate)
        soundinfo = note_perform.synth.soundinfo
        filter = AudioStream::Fx::HighShelfFilter.new(soundinfo)

        freq_mod = ModulationValue.balance_generator(note_perform, framerate, @freq)
        q_mod = ModulationValue.balance_generator(note_perform, framerate, @q)
        gain_mod = ModulationValue.balance_generator(note_perform, framerate, @gain)

        -> {
          filter.update_coef(freq: freq_mod[], q: q_mod[], gain: gain_mod[])
          filter
        }
      end
    end
  end
end
