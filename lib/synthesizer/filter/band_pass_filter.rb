module Synthesizer
  module Filter
    class BandPassFilter
      def initialize(freq:, bandwidth: 1.0)
        @freq = ModulationValue.create(freq)
        @bandwidth = ModulationValue.create(bandwidth)
      end

      def generator(soundinfo, note_perform, samplecount)
        filter = AudioStream::Fx::BandPassFilter.new(soundinfo)

        freq_mod = ModulationValue.balance_generator(soundinfo, note_perform, samplecount, @freq)
        bandwidth_mod = ModulationValue.balance_generator(soundinfo, note_perform, samplecount, @bandwidth)

        -> {
          filter.update_coef(freq: freq_mod[], bandwidth: bandwidth_mod[])
          filter
        }
      end
    end
  end
end
