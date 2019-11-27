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

      def generate_context(soundinfo, note_perform, init_phase)
        Context.new(soundinfo, note_perform, init_phase)
      end

      class Context < Base::Context
        attr_accessor :prev

        def initialize(soundinfo, note_perform, init_phase)
          super(soundinfo, note_perform, init_phase)

          @prev = -1.0
        end
      end
    end
  end
end
