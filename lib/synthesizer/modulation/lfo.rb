module Synthesizer
  module Modulation
    class Lfo

      # @param shape [Synthesizer::Shape]
      # @param delay [Float] delay sec (0.0~)
      # @param attack [Float] attack sec (0.0~)
      # @param attack_curve [Synthesizer::Curve]
      # @param phase [Float] phase percent (0.0~1.0)
      # @param rate [Float] wave freq (0.0~)
      def initialize(shape: Shape::Sine, delay: 0.0, attack: 0.0, attack_curve: Curve::Straight, phase: 0.0, rate: 3.5)
        @shape = shape
        @delay = delay
        @attack = attack
        @attack_curve = attack_curve
        @phase = phase
        @rate = rate
      end

      def generator(note_perform, framerate, &block)
        Enumerator.new do |yld|
          delta = @rate / framerate

          pos = ShapePos.new(phase: @phase)

          # delay
          rate = @delay * framerate
          rate.to_i.times {|i|
            yld << 0.0
          }

          # attack
          rate = @attack * framerate
          rate.to_i.times {|i|
            x = i.to_f / rate
            y = @attack_curve[x]
            yld << @shape[pos.next(delta)] * y
          }

          # sustain
          loop {
            val = @shape[pos.next(delta)]
            yld << val
          }
        end.each(&block)
      end

      def amp_generator(note_perform, framerate, depth, &block)
        bottom = 1.0 - depth

        generator(note_perform, framerate).lazy.map {|val|
          val = (val + 1) / 2
          val * depth + bottom
        }.each(&block)
      end

      def balance_generator(note_perform, framerate, depth, &block)
        generator(note_perform, framerate).lazy.map {|val|
          val * depth
        }.each(&block)
      end
    end
  end
end
