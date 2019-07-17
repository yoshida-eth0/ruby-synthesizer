module Synthesizer
  class Poly

    attr_reader :oscillators
    attr_reader :amplifier
    attr_reader :processor

    attr_reader :quality
    attr_reader :soundinfo

    attr_reader :glide
    attr_accessor :pitch_bend

    # @param oscillators [Synthesizer::Oscillator] Oscillator
    # @param amplifier [Synthesizer::Amplifier] amplifier
    # @param soundinfo [AudioStream::SoundInfo]
    def initialize(oscillators:, amplifier:, quality: Quality::LOW, soundinfo:)
      @oscillators = [oscillators].flatten.compact
      @amplifier = amplifier

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
