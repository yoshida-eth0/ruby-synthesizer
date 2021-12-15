module Synthesizer
  module Modulation
    class Lfo

      # @param shape [Synthesizer::Shape]
      # @param delay [AudioStream::Rate | Float] delay sec (0.0~)
      # @param attack [AudioStream::Rate | Float] attack sec (0.0~)
      # @param attack_curve [Synthesizer::Curve]
      # @param phase [Float] phase percent (0.0~1.0)
      # @param rate [AudioStream::Rate | Float] wave freq (0.0~)
      def initialize(shape: Shape::Sine, delay: 0.0, attack: 0.0, attack_curve: Curve::Straight, phase: 0.0, rate: 0.3)
        @shape = shape
        @delay = AudioStream::Rate.sec(delay)
        @attack = AudioStream::Rate.sec(attack)
        @attack_curve = attack_curve
        @phase = phase.to_f
        @rate = AudioStream::Rate.sec(rate)
      end

      def generator(soundinfo, note_perform, samplecount, &block)
        hz = @rate.freq(soundinfo)

        Enumerator.new do |yld|
          pos = ShapePos.new(soundinfo.samplerate / samplecount, @phase)

          # delay
          (@delay.sample(soundinfo) / samplecount).to_i.times {|i|
            yld << 0.0
          }

          # attack
          attack_len = (@attack.sample(soundinfo) / samplecount).to_i
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

      def amp_generator(soundinfo, note_perform, samplecount, depth, &block)
        bottom = 1.0 - depth
        gen = generator(soundinfo, note_perform, samplecount)

        -> {
          val = (gen.next + 1) / 2
          val * depth + bottom
        }
      end

      def balance_generator(soundinfo, note_perform, samplecount, depth, &block)
        gen = generator(soundinfo, note_perform, samplecount)

        -> {
          gen.next * depth
        }
      end
    end
  end
end
