module Synthesizer
  class PolySynth

    attr_reader :oscillators
    attr_reader :filter
    attr_reader :amplifier
    attr_reader :processor

    attr_reader :quality
    attr_reader :soundinfo

    attr_reader :glide
    attr_accessor :pitch_bend

    # @param oscillators [Synthesizer::Oscillator] Oscillator
    # @param filter [Synthesizer::Filter] filter
    # @param amplifier [Synthesizer::Amplifier] amplifier
    # @param soundinfo [AudioStream::SoundInfo]
    def initialize(oscillators:, filter: nil, amplifier:, quality: Quality::LOW, soundinfo:)
      @oscillators = [oscillators].flatten.compact
      @filter = filter
      @amplifier = amplifier

      @quality = quality
      @soundinfo = soundinfo

      @processor = Processor.create(quality)
      @performs = {}
      @pitch_bend = 0.0
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
      perform = @performs[note.num]
      if perform
        perform.note_off!
      end

      # Note On
      perform = NotePerform.new(self, note, velocity)
      @performs[note.num] = perform
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
