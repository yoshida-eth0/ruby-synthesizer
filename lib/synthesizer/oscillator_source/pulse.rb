module Synthesizer
  module OscillatorSource
    class Pulse < Square
      include Singleton

      def initialize
      end

      def sample(context, phase)
        val = super(context, phase)
        result = context.prev<0.0 && 0.0<val ? 1.0 : 0.0
        context.prev = val
        result
      end

      def generate_context(soundinfo, phase)
        PulseContext.new(soundinfo.window_size, soundinfo.channels, phase, ShapePos.new(phase: phase), -1.0)
      end

      PulseContext = Struct.new("PulseContext", :window_size, :channels, :phase, :pos, :prev)
    end
  end
end
