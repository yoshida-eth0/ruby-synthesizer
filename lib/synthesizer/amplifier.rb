module Synthesizer
  class Amplifier

    attr_reader :volume
    attr_reader :pan
    attr_reader :tune_semis
    attr_reader :tune_cents
    attr_reader :uni_num
    attr_reader :uni_detune
    attr_reader :uni_stereo

    # @param volume [Syntesizer::ModulationValue | Float] master volume. mute=0.0 max=1.0
    # @param pan [Syntesizer::ModulationValue | Float] master pan. left=-1.0 center=0.0 right=1.0 (-1.0~1.0)
    # @param tune_semis [Syntesizer::ModulationValue | Integer] master pitch semitone
    # @param tune_cents [Syntesizer::ModulationValue | Integer] master pitch cent
    # @param uni_num [Syntesizer::ModulationValue | Float] master voicing number (1.0~16.0)
    # @param uni_detune [Syntesizer::ModulationValue | Float] master voicing detune percent. 0.01=1cent 1.0=semitone (0.0~1.0)
    # @param uni_stereo [Syntesizer::ModulationValue | Float] oscillator voicing spread pan. -1.0=full inv 0.0=mono 1.0=full (-1.0~1.0)
    def initialize(volume: HARD_VOLUME, pan: 0.0, tune_semis: 0, tune_cents: 0, uni_num: 1.0, uni_detune: 0.0, uni_stereo: 0.0)
      @volume = ModulationValue.create(volume)
      @pan = ModulationValue.create(pan)
      @tune_semis = ModulationValue.create(tune_semis)
      @tune_cents = ModulationValue.create(tune_cents)

      @uni_num = ModulationValue.create(uni_num)
      @uni_detune = ModulationValue.create(uni_detune)
      @uni_stereo = ModulationValue.create(uni_stereo)
    end
  end


  SOFT_VOLUME = ModulationValue.new(0.0)
    .add(Modulation::Adsr::SOFT, depth: 1.0)
    .freeze

  HARD_VOLUME = ModulationValue.new(0.0)
    .add(Modulation::Adsr::HARD, depth: 1.0)
    .freeze

  KEEP = Amplifier.new(volume: 1.0)
  SOFT = Amplifier.new(volume: SOFT_VOLUME.dup)
  HARD = Amplifier.new(volume: HARD_VOLUME.dup)
end
