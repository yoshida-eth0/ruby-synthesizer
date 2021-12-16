module Synthesizer
  class FreqModulator

    attr_reader :synth
    attr_reader :freq

    # @param synth [Synthesizer::PolySynth] modulator synth
    # @param fixed_freq [AudioStream::Rate | Float] modulator fixed frequency
    # @param ratio_freq [Float] modulator ratio frequency
    def initialize(synth:, fixed_freq: nil, ratio_freq: nil)
      @synth = synth

      if fixed_freq
        @freq = Freq.fixed(fixed_freq)
      elsif ratio_freq
        @freq = Freq.ratio(ratio_freq)
      end
    end
  end
end
