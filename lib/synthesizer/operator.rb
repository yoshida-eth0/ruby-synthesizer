module Synthesizer
  class Operator

    attr_reader :source
    attr_reader :level
    attr_reader :fixed_freq
    attr_reader :ratio_freq
    attr_reader :envelope
    attr_reader :pmd
    attr_reader :amd

    # @param source [Synthesizer::OscillatorSource] operator waveform source
    # @param level [Float] operator amplification level. mute=0.0 max=1.0
    # @param fixed_freq [AudioStream::Rate | Float] carrier fixed frequency
    # @param ratio_freq [Float] carrier ratio frequency
    # @param envelope [Synthesizer::Modulation]
    # @param pmd [Float] pitch modulation depth for shared lfo
    # @param amd [Float] amplifier modulation depth for shared lfo
    def initialize(source: OscillatorSource::Sine.instance, level: 1.0, fixed_freq: nil, ratio_freq: nil, envelope:, pmd: 0.0, amd: 0.0)
      @source = source
      @level = level
      @fixed_freq = fixed_freq
      @ratio_freq = ratio_freq
      @envelope = envelope
      @pmd = pmd
      @amd = amd
    end
  end
end
