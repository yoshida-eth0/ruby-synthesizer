module Synthesizer
  module Filter
    class BandPassFilter
      def initialize(freq:, bandwidth: 1.0)
        @freq = ModulationValue.create(freq)
        @bandwidth = ModulationValue.create(bandwidth)
      end

      def generator(note_perform, framerate)
        soundinfo = note_perform.synth.soundinfo
        filter = AudioStream::Fx::BandPassFilter.new(soundinfo)

        freq_mod = ModulationValue.balance_generator(note_perform, framerate, @freq)
        bandwidth_mod = ModulationValue.balance_generator(note_perform, framerate, @bandwidth)

        -> {
          filter.update_coef(freq: freq_mod[], bandwidth: bandwidth_mod[])
          filter
        }
      end
    end
  end
end
