module Synthesizer
  class Oscillator

    attr_reader :source
    attr_reader :volume
    attr_reader :pan
    attr_reader :tune_semis
    attr_reader :tune_cents
    attr_reader :sym
    attr_reader :phase
    attr_reader :sync
    attr_reader :uni_num
    attr_reader :uni_detune
    attr_reader :uni_stereo

    # @param source [Synthesizer::OscillatorSource] oscillator waveform source
    # @param volume [Float] oscillator volume. mute=0.0 max=1.0
    # @param pan [Float] oscillator pan. left=-1.0 center=0.0 right=1.0 (-1.0~1.0)
    # @param tune_semis [Integer] oscillator pitch semitone
    # @param tune_cents [Integer] oscillator pitch cent
    # @param sym [nil] TODO not implemented
    # @param phase [Float] oscillator waveform shape start phase percent (0.0~1.0,nil) nil=random
    # @param sync [Integer] oscillator sync pitch 1.0=semitone 12.0=octave (0.0~48.0)
    # @param uni_num [Float] oscillator voicing number (1.0~16.0)
    # @param uni_detune [Float] oscillator voicing detune percent. 0.01=1cent 1.0=semitone (0.0~1.0)
    # @param uni_stereo [Float] oscillator voicing spread pan. -1.0=full inv 0.0=mono 1.0=full (-1.0~1.0)
    def initialize(source: OscillatorSource::Sine.instance, volume: 1.0, pan: 0.0, tune_semis: 0, tune_cents: 0, sym: 0, phase: nil, sync: 0, uni_num: 1.0, uni_detune: 0.0, uni_stereo: 0.0)
      @source = source

      @volume = ModulationValue.create(volume)
      @pan = ModulationValue.create(pan)
      @tune_semis = ModulationValue.create(tune_semis)
      @tune_cents = ModulationValue.create(tune_cents)

      @sym = ModulationValue.create(sym)
      @phase = ModulationValue.create(phase)
      @sync = ModulationValue.create(sync)

      @uni_num = ModulationValue.create(uni_num)
      @uni_detune = ModulationValue.create(uni_detune)
    end
  end
end
