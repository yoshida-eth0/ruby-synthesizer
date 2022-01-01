module Synthesizer
  module Modulation
    class Adsr
      include AmpEnvelope

      # @param attack [AudioStream::Rate | Float] attack sec (0.0~)
      # @param attack_curve [Synthesizer::Curve]
      # @param hold [AudioStream::Rate | Float] hold sec (0.0~)
      # @param decay [AudioStream::Rate | Float] decay sec (0.0~)
      # @param sustain_curve [Synthesizer::Curve]
      # @param sustain [Float] sustain level (0.0~1.0)
      # @param release [AudioStream::Rate | Float] release sec (0.0~)
      # @param release_curve [Synthesizer::Curve]
      def initialize(attack:, attack_curve: Curve::EaseOut, hold: 0.0, decay:, sustain_curve: Curve::EaseOut, sustain:, release:, release_curve: Curve::EaseOut)
        @attack = AudioStream::Rate.sec(attack)
        @attack_curve = attack_curve
        @hold = AudioStream::Rate.sec(hold)
        @decay = AudioStream::Rate.sec(decay)
        @sustain_curve = sustain_curve
        @sustain = sustain
        @release = AudioStream::Rate.sec(release)
        @release_curve = release_curve
      end

      def create_context(soundinfo)
        nil
      end

      def note_on_envelope(soundinfo, samplecount, sustain: false, &block)
        Enumerator.new do |yld|
          # attack
          attack_len = (@attack.sample(soundinfo) / samplecount).to_i
          attack_len.times {|i|
            x = i.to_f / attack_len
            y = @attack_curve[x]
            yld << y
          }

          # hold
          (@hold.sample(soundinfo) / samplecount).to_i.times {|i|
            yld << 1.0
          }

          # decay
          decay_len = (@decay.sample(soundinfo) / samplecount).to_i
          decay_len.times {|i|
            x = i.to_f / decay_len
            y = 1.0 - @sustain_curve[x] * (1.0 - @sustain)
            yld << y
          }

          # sustain
          if sustain
            loop {
              yld << @sustain
            }
          end
        end.each(&block)
      end

      def note_off_envelope(soundinfo, samplecount, last_level, sustain: false, &block)
        Enumerator.new do |yld|
          # release
          release_len = (@release.sample(soundinfo) / samplecount).to_i
          release_len.times {|i|
            x = i.to_f / release_len
            y = 1.0 - @release_curve[x]
            yld << y * last_level
          }
          yld << 0.0

          # sustain
          if sustain
            loop {
              yld << 0.0
            }
          end
        end.each(&block)
      end

      def generator(soundinfo, note_perform, samplecount, release_sustain:)
        note_on = note_on_envelope(soundinfo, samplecount, sustain: true)
        note_off = nil
        last_level = 0.0

        -> {
          if note_perform.note_on?
            last_level = note_on.next
          else
            note_off ||= note_off_envelope(soundinfo, samplecount, last_level, sustain: release_sustain)
            note_off.next
          end
        }
      end

      def plot_data(soundinfo, sustain: 0.0)
        samplecount = soundinfo.window_size.to_f
        note_on = note_on_envelope(soundinfo, samplecount, sustain: false)
        sustain = AudioStream::Rate.sec(sustain)

        xs = []
        ys = []
        last_level = nil

        note_on.each {|y|
          xs << xs.length
          ys << y
          last_level = y
        }

        if last_level
          sustain_len = (sustain.sample(soundinfo) / samplecount).to_i
          sustain_len.times {|i|
            xs << xs.length
            ys << last_level
          }
        end

        last_level = ys.last || 0.0
        note_off = note_off_envelope(soundinfo, samplecount, last_level, sustain: false)
        note_off.each {|y|
          xs << xs.length
          ys << y
        }

        {x: xs, y: ys}
      end

      def plot(soundinfo, sustain: 0.0)
        data = plot_data(soundinfo, sustain: sustain)
        Plotly::Plot.new(data: [data])
      end


      KEEP = Adsr.new(
        attack: 0.0,
        hold: 0.0,
        decay: 0.0,
        sustain: 1.0,
        release: 1.0
      )

      NONE = Adsr.new(
        attack: 0.0,
        hold: 0.0,
        decay: 0.0,
        sustain: 0.0,
        release: 0.0
      )

      SOFT = Adsr.new(
        attack: 0.05,
        hold: 0.1,
        decay: 0.4,
        sustain: 0.8,
        release: 0.2
      )

      HARD = Adsr.new(
        attack: 0.0,
        hold: 0.0,
        decay: 0.0,
        sustain: 1.0,
        release: 0.0
      )
    end
  end
end
