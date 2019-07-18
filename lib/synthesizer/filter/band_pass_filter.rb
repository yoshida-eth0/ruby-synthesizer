module Synthesizer
  module Filter
    class BandPassFilter
      def initialize(freq:, bandwidth:)
        @freq = ModulationValue.create(freq)
        @bandwidth = ModulationValue.create(bandwidth)
      end

      def generator(note_perform, framerate, &block)
        Enumerator.new do |y|
          soundinfo = note_perform.synth.soundinfo
          filter = AudioStream::Fx::BandPassFilter.new(soundinfo)

          freq_mod = ModulationValue.balance_generator(note_perform, framerate, @freq)
          bandwidth_mod = ModulationValue.balance_generator(note_perform, framerate, @bandwidth)

          loop {
            filter.update_coef(freq: freq_mod.next, bandwidth: bandwidth_mod.next)
            y << filter
          }
        end.each(&block)
      end
    end
  end
end
