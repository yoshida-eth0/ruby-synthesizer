module Synthesizer
  module OscillatorSource
    Shape.constants.each {|a|
      eval "class #{a} < Base
              include Singleton

              def sample(context, phase)
                Shape::#{a}[phase]
              end
            end"
    }
  end
end
