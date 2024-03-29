module Synthesizer
  module Modulation
    class Glide

      # @param time [AudioStream::Rate | Float] glide time sec (0.0~)
      def initialize(time:)
        @time = AudioStream::Rate.sec(time)

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

      def generator(soundinfo, note_perform, samplecount)
        rate = @time.sample(soundinfo) / samplecount

        -> {
          ret = nil

          if !note_perform.released?
            # Note On
            if 0<rate && @target!=@current
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

      def balance_generator(soundinfo, note_perform, samplecount, depth)
        gen = generator(soundinfo, note_perform, samplecount)

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
