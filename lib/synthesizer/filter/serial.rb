module Synthesizer
  module Filter
    class Serial
      def initialize(*filters)
        @filters = filters
      end

      def generator(note_perform, samplecount)
        filter_mods = @filters.map {|filter|
          filter.generator(note_perform, samplecount)
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
          @fxs.each {|fx|
            input = fx.process(input)
          }
          input
        end
      end
    end
  end
end
