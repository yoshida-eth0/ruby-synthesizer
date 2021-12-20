module Synthesizer
  class FmSynth

    # @param operators [Hash[Symbol,Synthesizer::Oscillator]] key: Operator ID, value: Operator
    # @param algorithm [Synthesizer::Algorithm] modulation algorithm
    # @param pitch_envelope [Synthesizer::Modulation::Dx7PitchEnvelope] shared pitch envelope
    # @param lfo [Synthesizer::Modulation::Lfo] shared lfo
    def initialize(operators: {}, algorithm: Algorithm.new, lfo: Modulation::Lfo::KEEP, pitch_envelope: Modulation::Dx7PitchEnvelope::KEEP, quality: Quality::LOW, soundinfo:)
      @operators = operators
      @algorithm = algorithm
      @lfo = lfo
      @pitch_envelope = pitch_envelope
      @quality = quality
      @soundinfo = soundinfo
    end

    def add_operator(id, operator)
      @operators[id] = operator
      self
    end

    def build
      # create oscillators
      oscillators = @operators.map {|id,operator|
        [
          id,
          Oscillator.new(
            source: operator.source,
            volume: ModulationValue.new(0.0)
              .add(operator.envelope, depth: 1.0, level: operator.level)
              .add(@lfo, depth: operator.amd),
            fixed_freq: operator.fixed_freq,
            ratio_freq: operator.ratio_freq,
            tune_cents: ModulationValue.new(0.0)
              .add(@lfo, depth: operator.pmd)
              #.add(@pitch_envelope, depth: 99.0/32.0/2)
              .add(@pitch_envelope, depth: 99)
            )
        ]
      }.to_h

      synthes = {}

      # connect modulator and carrier
      @algorithm.route.each {|carrier_id, modulator_ids|
        # operator id check
        ids = [carrier_id] + modulator_ids.to_a
        ids.each {|id|
          if !oscillators[id]
            raise Error, "not found operator: #{id}"
          end
        }

        # connect
        carrier_osc = oscillators[carrier_id]
        modulator_ids.each {|modulator_id|
          # create modulator synth
          synthes[modulator_id] ||= PolySynth.new(
            oscillators: [
              oscillators[modulator_id],
            ],
            amplifier: Amplifier::KEEP,
            quality: @quality,
            soundinfo: @soundinfo,
          )

          # connect
          carrier_osc.freq_modulators << synthes[modulator_id]
        }
      }

      # create carrier synth
      carrier_ids = @operators.keys - @algorithm.modulator_ids
      PolySynth.new(
        oscillators: carrier_ids.map{|id| oscillators[id]},
        amplifier: Amplifier::KEEP,
        quality: @quality,
        soundinfo: @soundinfo,
      )
    end
  end
end
