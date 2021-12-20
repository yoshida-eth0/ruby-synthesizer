module Synthesizer
  class DrumMachineDesigner

    attr_reader :soundinfo
    attr_reader :synth_map
    attr_reader :note_map

    def initialize(soundinfo)
      @soundinfo = soundinfo
      @synth_map = {}
      @note_map = {}
      @performs = {}
    end

    # @param note [Synthesizer::Note]
    # @param synth [Synthesizer::PolySynth]
    # @param override_note [Syntheizer::Note]
    def assign(note, synth, override_note=nil)
      @synth_map[note.num] = synth
      @note_map[note.num] = override_note
    end

    def next
      buf = nil
      if 0<@performs.length
        bufs = @performs.values.map(&:next).compact

        # delete released note performs
        @performs.delete_if {|note_num, perform| perform.released? }

        if 0<bufs.length
          buf = AudioStream::Buffer.merge(bufs)
        end
      end
      buf || AudioStream::Buffer.create(@soundinfo.window_size, @soundinfo.channels)
    end

    # @param note [Synthesizer::Note]
    # @param velocity [Float] volume percent (0.0~1.0)
    def note_on(note, velocity: 1.0)
      # Note Off
      note_off(note)

      # Note On
      synth = @synth_map[note.num]
      override_note = @note_map[note.num]
      if synth
        perform = NotePerform.new(synth, override_note || note, velocity)
        @performs[note.num] = perform
      end
    end

    # @param note [Synthesizer::Note]
    def note_off(note)
      # Note Off
      perform = @performs[note.num]
      if perform
        perform.note_off!
      end
    end
  end
end
