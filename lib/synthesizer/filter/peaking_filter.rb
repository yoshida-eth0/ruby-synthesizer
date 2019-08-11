module Synthesizer
  module Filter
    class PeakingFilter
      def initialize(freq:, bandwidth: 1.0, gain: 40.0)
        @freq = ModulationValue.create(freq)
        @bandwidth = ModulationValue.create(bandwidth)
        @gain = ModulationValue.create(gain)
      end

      def generator(note_perform, framerate, &block)
        Enumerator.new do |y|
          soundinfo = note_perform.synth.soundinfo
          filter = AudioStream::Fx::LowShelfFilter.new(soundinfo)

          freq_mod = ModulationValue.balance_generator(note_perform, framerate, @freq)
          bandwidth_mod = ModulationValue.balance_generator(note_perform, framerate, @bandwidth)
          gain_mod = ModulationValue.balance_generator(note_perform, framerate, @gain)

          loop {
            filter.update_coef(freq: freq_mod.next, bandwidth: bandwidth_mod.next, gain: gain_mod.next)
            y << filter
          }
        end.each(&block)
      end
    end
  end
end
