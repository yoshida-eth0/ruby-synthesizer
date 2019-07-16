module Synthesizer
  class Poly

    attr_reader :oscs
    attr_reader :amp
    attr_reader :processor

    attr_reader :quality
    attr_reader :soundinfo

    attr_reader :glide
    attr_accessor :pitch_bend

    # @param oscs [Osc] Oscillator
    # @param amp [Amp] amplifier
    # @param soundinfo [SoundInfo]
    def initialize(oscs:, amp:, quality: Quality::LOW, soundinfo:)
      @oscs = [oscs].flatten.compact
      @amp = amp

      @quality = quality
      @soundinfo = soundinfo

      @processor = Processor.create(quality)
      @performs = {}
      @pitch_bend = 0.0
    end

    def next
      if 0<@performs.length
        bufs = @performs.values.map(&:next)

        # delete released note performs
        @performs.delete_if {|note_num, perform| perform.released? }

        bufs.compact.inject(:+)
      else
        AudioStream::Buffer.float(@soundinfo.window_size, @soundinfo.channels)
      end
    end

    def note_on(note)
      # Note Off
      perform = @performs[note.num]
      if perform
        perform.note_off!
      end

      # Note On
      perform = NotePerform.new(self, note)
      @performs[note.num] = perform
    end

    def note_off(note)
      # Note Off
      perform = @performs[note.num]
      if perform
        perform.note_off!
      end
    end
  end
end
