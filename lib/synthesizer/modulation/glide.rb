module Synthesizer
  module Modulation
    class Glide

      # @param time [Float] glide time sec (0.0~)
      def initialize(time:)
        @time = time.to_f

        @base = 0.0
        @current = 0.0
        @target = 0.0
        @diff = 0.0
      end

      def base=(base)
        base = base.to_f

        @base = base
        @current = base
        @target = base
        @diff = 0.0
      end

      def target=(target)
        @target = target
        @diff = target - @current
      end

      def generator(note_perform, samplerate)
        rate = @time * samplerate

        -> {
          ret = nil

          if !note_perform.released?
            # Note On
            if 0<@time && @target!=@current
              # Gliding
              x = @diff / rate
              if x.abs<(@target-@current).abs
                @current += x
              else
                @current = @target
              end

              ret = @current - @base
            else
              # Stay
              ret = @target - @base
            end
          else
            # Note Off
            @current = 0.0
            @target = 0.0
            @diff = 0.0
            ret = 0.0
          end

          ret
        }
      end

      def balance_generator(note_perform, samplerate, depth)
        gen = generator(note_perform, samplerate)

        -> {
          gen[] * depth
        }
      end

      def to_modval
        @modval ||= ModulationValue.create(0).add(self)
      end
    end
  end
end
