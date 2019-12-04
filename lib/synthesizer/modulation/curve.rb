module Synthesizer
  module Modulation
    module Curve
      Straight = ->(x) { x }
      EaseIn = ->(x) { x ** 2 }
      EaseOut = ->(x) { x * (2 - x) }

      EaseIn2 = ->(x) { x ** 3 }
      EaseOut2 = ->(x) { 1.0 - EaseIn2[1.0 - x]}
    end
  end
end
