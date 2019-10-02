module Synthesizer
  class NotePerform

    attr_reader :synth
    attr_reader :note
    attr_reader :velocity

    def initialize(synth, note, velocity)
      @synth = synth
      @note = note
      @velocity = velocity

      @processors = synth.oscillators.map {|osc|
        synth.processor.generator(osc, self)
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
