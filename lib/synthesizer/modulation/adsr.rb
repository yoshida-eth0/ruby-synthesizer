module Synthesizer
  module Modulation
    class Adsr

      # @param attack [Float] attack sec (0.0~)
      # @param attack_curve [Synthesizer::Curve]
      # @param hold [Float] hold sec (0.0~)
      # @param decay [Float] decay sec (0.0~)
      # @param sustain_curve [Synthesizer::Curve]
      # @param sustain [Float] sustain sec (0.0~)
      # @param release [Float] release sec (0.0~)
      # @param release_curve [Synthesizer::Curve]
      def initialize(attack:, attack_curve: Curve::EaseOut, hold: 0.0, decay:, sustain_curve: Curve::EaseOut, sustain:, release:, release_curve: Curve::EaseOut)
        @attack = attack
        @attack_curve = attack_curve
        @hold = hold
        @decay = decay
        @sustain_curve = sustain_curve
        @sustain = sustain
        @release = release
        @release_curve = release_curve
      end

      def note_on_envelope(framerate, sustain: false, &block)
        Enumerator.new do |yld|
          # attack
          rate = @attack * framerate
          rate.to_i.times {|i|
            x = i.to_f / rate
            y = @attack_curve[x]
            yld << y
          }

          # hold
          rate = @hold * framerate
          rate.to_i.times {|i|
            yld << 1.0
          }

          # decay
          rate = @decay * framerate
          rate.to_i.times {|i|
            x = i.to_f / rate
            y = 1.0 - @sustain_curve[x]  * (1.0 - @sustain)
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

      def note_off_envelope(framerate, sustain: false, &block)
        Enumerator.new do |yld|
          # release
          rate = @release * framerate
          rate.to_i.times {|i|
            x = i.to_f / rate
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

      def generator(note_perform, framerate, release_sustain:)
        note_on = note_on_envelope(framerate, sustain: true)
        note_off = note_off_envelope(framerate, sustain: release_sustain)
        last = 0.0

        -> {
          if note_perform.note_on?
            last = note_on.next
          else
            note_off.next * last
          end
        }
      end


      def amp_generator(note_perform, framerate, depth, &block)
        bottom = 1.0 - depth
        gen = generator(note_perform, framerate, release_sustain: 0.0<bottom)

        -> {
          gen[] * depth + bottom
        }
      end

      def balance_generator(note_perform, framerate, depth, &block)
        gen = generator(note_perform, framerate, release_sustain: true)

        -> {
          gen[] * depth
        }
      end

      def plot_data(framerate: 44100)
        note_on = note_on_envelope(framerate, sustain: false)
        note_off = note_off_envelope(framerate, sustain: false)
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

      def plot(framerate: 44100)
        data = plot_data(framerate: framerate)
        Plotly::Plot.new(data: [data])
      end
    end
  end
end
