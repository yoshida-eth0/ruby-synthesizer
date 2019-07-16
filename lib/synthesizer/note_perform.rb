module Synthesizer
  class NotePerform

    attr_reader :synth
    attr_reader :note

    def initialize(synth, note)
      @synth = synth
      @processors = synth.oscs.map {|osc|
        synth.processor.generator(osc, self)
      }

      @note = note
      @note_on = true
      @released = false
    end

    def next
      begin
        @processors.map(&:next).inject(:+)
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
