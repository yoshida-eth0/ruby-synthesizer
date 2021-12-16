require 'forwardable'

module Synthesizer
  class NotePerform

    attr_reader :note
    attr_reader :velocity

    def initialize(synth, note, velocity, carrier_freq)
      @note = note
      @velocity = velocity
      freq ||= Freq.ratio(1.0)

      @processors = synth.oscillators.map {|osc|
        synth.processor.generator(osc, synth, self, carrier_freq)
      }

      @note_on = true
      @released = false
    end

    def next
      begin
        @processors.map(&:[]).inject(:+)
      rescue StopIteration => e
        @released = true
        nil
      end
    end

    def note_on?
      @note_on
    end

    def note_off!
      @note_on = false
    end

    def released?
      @released
    end
  end
end
