module Synthesizer
  class Mono

    attr_reader :oscillators
    attr_reader :filter
    attr_reader :amplifier
    attr_reader :processor

    attr_reader :quality
    attr_reader :soundinfo

    attr_reader :glide
    attr_accessor :pitch_bend

    # @param oscillators [Synthesizer::Oscillator] oscillator
    # @param amplifier [Synthesizer::Amplifier] amplifier
    # @param soundinfo [AudioStream::SoundInfo]
    def initialize(oscillators:, filter: nil, amplifier:, glide: 0.1, quality: Quality::LOW, soundinfo:)
      @oscillators = [oscillators].flatten.compact
      @filter = filter
      @amplifier = amplifier

      @quality = quality
      @soundinfo = soundinfo

      @processor = Processor.create(quality)
      @note_nums = []
      @perform = nil
      @glide = Modulation::Glide.new(time: glide)
      @pitch_bend = 0.0
    end

    def next
      if @perform
        buf = @perform.next

        # delete released note perform
        if @perform.released?
          @perform = nil
        end

        buf
      else
        AudioStream::Buffer.float(@soundinfo.window_size, @soundinfo.channels)
      end
    end

    def note_on(note)
      # Note Off
      note_off(note)

      if @perform && @perform.note_on?
        # Glide
        @glide.target = note.num
      else
        # Note On
        @perform = NotePerform.new(self, note)
        @glide.base = note.num
      end
      @note_nums << note.num        
    end

    def note_off(note)
      # Note Off
      @note_nums.delete_if {|note_num| note_num==note.num}

      if @perform
        if @note_nums.length==0
          # Note Off
          @perform.note_off!
        else
          # Glide
          @glide.target = @note_nums.last
        end
      end
    end
  end
end
