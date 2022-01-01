module Synthesizer
  module Modulation
    module AmpEnvelope

      def amp_generator(soundinfo, note_perform, samplecount, depth, &block)
        bottom = 1.0 - depth
        gen = generator(soundinfo, note_perform, samplecount, release_sustain: 0.0<bottom)

        -> {
          gen[] * depth + bottom
        }
      end

      def balance_generator(soundinfo, note_perform, samplecount, depth, &block)
        gen = generator(soundinfo, note_perform, samplecount, release_sustain: true)

        -> {
          gen[] * depth
        }
      end
    end
  end
end
