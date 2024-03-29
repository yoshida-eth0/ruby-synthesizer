module Synthesizer
  module Filter
    class Parallel
      def initialize(*filters)
        @filters = filters
      end

      def generator(soundinfo, note_perform, samplecount)
        filter_mods = @filters.map {|filter|
          filter.generator(soundinfo, note_perform, samplecount)
        }

        -> {
          fxs = filter_mods.map(&:[])
          Fx.new(fxs)
        }
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
