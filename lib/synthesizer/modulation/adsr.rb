module Synthesizer
  module Modulation
    class Adsr

      # @param attack [AudioStream::Rate] attack sec (0.0~)
      # @param attack_curve [Synthesizer::Curve]
      # @param hold [AudioStream::Rate] hold sec (0.0~)
      # @param decay [AudioStream::Rate] decay sec (0.0~)
      # @param sustain_curve [Synthesizer::Curve]
      # @param sustain [Float] sustain level (0.0~1.0)
      # @param release [AudioStream::Rate] release sec (0.0~)
      # @param release_curve [Synthesizer::Curve]
      def initialize(attack:, attack_curve: Curve::EaseOut, hold: AudioStream::Rate.sec(0.0), decay:, sustain_curve: Curve::EaseOut, sustain:, release:, release_curve: Curve::EaseOut)
        @attack = attack
        @attack_curve = attack_curve
        @hold = hold
        @decay = decay
        @sustain_curve = sustain_curve
        @sustain = sustain
        @release = release
        @release_curve = release_curve
      end

      def note_on_envelope(soundinfo, sustain: false, &block)
        Enumerator.new do |yld|
          # attack
          attack_len = @attack.frame(soundinfo).to_i
          attack_len.times {|i|
            x = i.to_f / attack_len
            y = @attack_curve[x]
            yld << y
          }

          # hold
          @hold.frame(soundinfo).to_i.times {|i|
            yld << 1.0
          }

          # decay
          decay_len = @decay.frame(soundinfo).to_i
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

      def note_off_envelope(soundinfo, sustain: false, &block)
        Enumerator.new do |yld|
          # release
          release_len = @release.frame(soundinfo).to_i
          release_len.times {|i|
            x = i.to_f / release_len
            y = 1.0 - @release_curve[x]
            yld << y
          }

          # sustain
          if sustain
            loop {
              yld << 0.0
            }
          end
        end.each(&block)
      end

      def generator(note_perform, release_sustain:)
        soundinfo = note_perform.synth.soundinfo

        note_on = note_on_envelope(soundinfo, sustain: true)
        note_off = note_off_envelope(soundinfo, sustain: release_sustain)
        last = 0.0

        -> {
          if note_perform.note_on?
            last = note_on.next
          else
            note_off.next * last
          end
        }
      end


      def amp_generator(note_perform, depth, &block)
        bottom = 1.0 - depth
        gen = generator(note_perform, release_sustain: 0.0<bottom)

        -> {
          gen[] * depth + bottom
        }
      end

      def balance_generator(note_perform, depth, &block)
        gen = generator(note_perform, release_sustain: true)

        -> {
          gen[] * depth
        }
      end

      def plot_data(soundinfo)
        note_on = note_on_envelope(soundinfo, sustain: false)
        note_off = note_off_envelope(soundinfo, sustain: false)
        last = 0.0

        xs = []
        ys = []

        note_on.each {|y|
          xs << xs.length
          ys << y
        }

        last = ys.last || 0.0
        note_off.each {|y|
          xs << xs.length
          ys << y * last
        }

        {x: xs, y: ys}
      end

      def plot(soundinfo)
        data = plot_data(soundinfo)
        Plotly::Plot.new(data: [data])
      end
    end
  end
end
