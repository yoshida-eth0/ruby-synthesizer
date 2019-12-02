module Synthesizer
  class MonoSynth

    attr_reader :oscillators
    attr_reader :filter
    attr_reader :amplifier
    attr_reader :processor

    attr_reader :soundinfo

    attr_reader :glide
    attr_accessor :pitch_bend

    # @param oscillators [Synthesizer::Oscillator] oscillator
    # @param filter [Synthesizer::Filter] filter
    # @param amplifier [Synthesizer::Amplifier] amplifier
    # @param glide [AudioStream::Rate] glide time sec (0.0~)
    # @param soundinfo [AudioStream::SoundInfo]
    def initialize(oscillators:, filter: nil, amplifier:, glide: AudioStream::Rate.sec(0.1), soundinfo:)
      @oscillators = [oscillators].flatten.compact
      @filter = filter
      @amplifier = amplifier

      @soundinfo = soundinfo

      @processor = Processor.new
      @note_nums = []
      @perform = nil
      @glide = Modulation::Glide.new(time: glide)
      @pitch_bend = 0.0
    end

    def next
      buf = nil
      if @perform
        buf = @perform.next

        # delete released note perform
        if @perform.released?
          @perform = nil
        end
      end
      buf || AudioStream::Buffer.create(@soundinfo.window_size, @soundinfo.channels)
    end

    # @param note [Synthesizer::Note]
    # @param velocity [Float] volume percent (0.0~1.0)
    def note_on(note, velocity: 1.0)
      # Note Off
      note_off(note)

      if @perform && @perform.note_on?
        # Glide
        @glide.target = note.num
      else
        # Note On
        @perform = NotePerform.new(self, note, velocity)
        @glide.base = note.num
      end
      @note_nums << note.num        
    end

    # @param note [Synthesizer::Note]
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
