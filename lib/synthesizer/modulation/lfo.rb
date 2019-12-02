module Synthesizer
  module Modulation
    class Lfo

      # @param shape [Synthesizer::Shape]
      # @param delay [AudioStream::Rate] delay sec (0.0~)
      # @param attack [AudioStream::Rate] attack sec (0.0~)
      # @param attack_curve [Synthesizer::Curve]
      # @param phase [Float] phase percent (0.0~1.0)
      # @param rate [AudioStream::Rate] wave freq (0.0~)
      def initialize(shape: Shape::Sine, delay: AudioStream::Rate.sec(0.0), attack: AudioStream::Rate.sec(0.0), attack_curve: Curve::Straight, phase: 0.0, rate: AudioStream::Rate.freq(3.5))
        @shape = shape
        @delay = delay
        @attack = attack
        @attack_curve = attack_curve
        @phase = phase
        @rate = rate
      end

      def generator(note_perform, &block)
        soundinfo = note_perform.synth.soundinfo
        hz = @rate.freq(soundinfo)

        Enumerator.new do |yld|
          pos = ShapePos.new(soundinfo.samplerate, @phase)

          # delay
          @delay.frame(soundinfo).to_i.times {|i|
            yld << 0.0
          }

          # attack
          attack_len = @attack.frame(soundinfo).to_i
          attack_len.times {|i|
            x = i.to_f / attack_len
            y = @attack_curve[x]
            yld << @shape[pos.next(hz, 0.0, 0.0)] * y
          }

          # sustain
          loop {
            val = @shape[pos.next(hz, 0.0, 0.0)]
            yld << val
          }
        end.each(&block)
      end

      def amp_generator(note_perform, depth, &block)
        bottom = 1.0 - depth
        gen = generator(note_perform)

        -> {
          val = (gen.next + 1) / 2
          val * depth + bottom
        }
      end

      def balance_generator(note_perform, depth, &block)
        gen = generator(note_perform)

        -> {
          gen.next * depth
        }
      end
    end
  end
end
