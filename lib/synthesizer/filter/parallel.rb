module Synthesizer
  module Filter
    class Parallel
      def initialize(*filters)
        @filters = filters
      end

      def generator(note_perform, framerate, &block)
        Enumerator.new do |y|
          filter_mods = @filters.map {|filter|
            filter.generator(note_perform, framerate)
          }

          loop {
            fxs = filter_mods.map(&:next)
            y << Fx.new(fxs)
          }
        end.each(&block)
      end

      class Fx
        include AudioStream::Fx::BangProcess

        def initialize(fxs)
          @fxs = fxs
        end

        def process!(input)
          window_size = input.size
          channels = input.channels
          fx_size = @fxs.size

          outputs = @fxs.map {|fx|
            fx.process(input)
          }

          case channels
          when 1
            input.size.times {|i|
              input[i] = outputs.map{|buf| buf[i]}.sum / fx_size
            }
          when 2
            input.size.times {|i|
              samples = outputs.map{|buf| buf[i]}
              input[i] = [
                samples.map{|sval| sval[0]}.sum / fx_size,
                samples.map{|sval| sval[1]}.sum / fx_size
              ]
            }
          end

          input
        end
      end
    end
  end
end
