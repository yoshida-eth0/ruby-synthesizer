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
        def initialize(fxs)
          @fxs = fxs
        end

        def process(input)
          outputs = @fxs.map {|fx|
            fx.process(input)
          }
          AudioStream::Buffer.merge(outputs, average: true)
        end
      end
    end
  end
end
