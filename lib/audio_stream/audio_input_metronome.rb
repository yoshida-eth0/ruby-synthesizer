module AudioStream
  class AudioInputMetronome
    include AudioInput

    def initialize(bpm:, beat: 4, repeat: nil, soundinfo:)
      super()

      @bpm = bpm
      @beat = beat.to_i
      @repeat = repeat

      @synth = Synthesizer::PolySynth.new(
        oscillators: Synthesizer::Oscillator.new(
          shape: Synthesizer::Shape::Sine,
          phase: 0,
        ),
        amplifier: Synthesizer::Amplifier.new(
          volume: Synthesizer::ModulationValue.new(1.0)
            .add(Synthesizer::Modulation::Adsr.new(
              attack: 0.0,
              hold: 0.05,
              decay: 0.0,
              sustain: 0.0,
              release: 0.0
            ), depth: 1.0),
        ),
        quality: Synthesizer::Quality::LOW,
        soundinfo: soundinfo,
      )

      @soundinfo = soundinfo
    end

    def each(&block)
      Enumerator.new do |y|
        period = @soundinfo.samplerate.to_f / @soundinfo.window_size * 60.0 / @bpm
        repeat_count = 0.0
        beat_count = 0

        Range.new(0, @repeat).each {|_|
          if repeat_count<1
            if beat_count==0
              @synth.note_on(Synthesizer::Note.new(81))
            else
              @synth.note_on(Synthesizer::Note.new(69))
            end
            beat_count = (beat_count + 1) % @beat
          end
          y << @synth.next
          repeat_count = (repeat_count + 1) % period
        }
      end.each(&block)
    end
  end
end
