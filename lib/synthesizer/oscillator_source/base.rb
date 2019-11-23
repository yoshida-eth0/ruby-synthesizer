module Synthesizer
  module OscillatorSource
    class Base
      def initialize
      end

      def next(context, delta, l_gain, r_gain)
        channels = context.channels
        window_size = context.window_size
        pos = context.pos

        dst = window_size.times.map {|i|
          sample(context, pos.next(delta))
        }
        dst = Vdsp::DoubleArray.create(dst)

        case channels
        when 1
          Buffer.new(dst * l_gain)
        when 2
          Buffer.new(dst * l_gain, dst * r_gain)
        end
      end

      def sample(context, phase)
        raise Error, "not implemented abstruct method: #{self.class.name}.sample(context, phase)"
      end

      def generate_context(soundinfo, note_perform, phase)
        Context.new(soundinfo.window_size, soundinfo.channels, ShapePos.new(phase: phase))
      end

      Context = Struct.new("Context", :window_size, :channels, :pos)
    end
  end
end
