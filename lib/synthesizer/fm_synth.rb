module Synthesizer
  class FmSynth

    # @param operators [Hash[Symbol,Synthesizer::Oscillator]] key: Operator ID, value: Operator
    # @param algorithm [Hash[Symbol,Symbol]] key: Modulator ID, value: Carrier ID
    # @param lfo [Synthesizer::Modulation::Lfo] shared lfo
    def initialize(operators: {}, algorithm: {}, carriers: [], lfo:, quality: Quality::LOW, soundinfo:)
      @operators = operators

      @algo_route = {}
      algorithm.each {|modulator_id, carrier_id|
        add_algorithm(modulator_id, carrier_id)
      }

      @carriers = [carriers].flatten.compact
      @lfo = lfo

      @quality = quality
      @soundinfo = soundinfo
    end

    def add_operator(id, operator)
      @operators[id] = operator
      self
    end

    def add_algorithm(modulator_id, carrier_id)
      @algo_route[carrier_id] ||= []
      @algo_route[carrier_id] << modulator_id
      self
    end

    def build
      @carriers.each {|id|
        if !@operators[id]
          raise Error, "not found operator: #{id}"
        end
      }

      # create oscillators
      oscillators = @operators.map {|id,operator|
        [
          id,
          Oscillator.new(
            source: operator.source,
            volume: ModulationValue.new(0.0)
              .add(operator.envelope, depth: operator.level)
              .add(@lfo, depth: operator.amd),
            fixed_freq: operator.fixed_freq,
            ratio_freq: operator.ratio_freq,
            tune_cents: ModulationValue.new(0.0)
              .add(@lfo, depth: operator.pmd)
            )
        ]
      }.to_h

      synthes = {}

      # connect modulator and carrier
      @algo_route.each {|carrier_id, modulator_ids|
        # operator id check
        ids = [carrier_id] + modulator_ids
        ids.each {|id|
          if !oscillators[id]
            raise Error, "not found operator: #{id}"
          end
        }

        # connect
        carrier_osc = oscillators[carrier_id]
        modulator_ids.each {|modulator_id|
          # create synth
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

      # create output synth
      PolySynth.new(
        oscillators: @carriers.map{|id| oscillators[id]},
        amplifier: Amplifier::KEEP,
        quality: @quality,
        soundinfo: @soundinfo,
      )
    end
  end
end
