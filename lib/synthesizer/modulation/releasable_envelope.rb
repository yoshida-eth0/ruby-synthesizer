module Synthesizer
  module Modulation
    module ReleasableEnvelope

      def note_on_envelope(soundinfo, samplecount, sustain: false, &block)
        raise Error, "not implemented abstruct method: #{self.class.name}.note_on_envelope(soundinfo, samplecount, sustain:, &block)"
      end

      def note_off_envelope(soundinfo, samplecount, sustain: false, &block)
        raise Error, "not implemented abstruct method: #{self.class.name}.note_off_envelope(soundinfo, samplecount, sustain:, &block)"
      end

      def generator(soundinfo, note_perform, samplecount, release_sustain:)
        note_on = note_on_envelope(soundinfo, samplecount, sustain: true)
        note_off = note_off_envelope(soundinfo, samplecount, sustain: release_sustain)
        last = 0.0

        -> {
          if note_perform.note_on?
            last = note_on.next
          else
            note_off.next * last
          end
        }
      end


      def amp_generator(soundinfo, note_perform, samplecount, depth, &block)
        bottom = 1.0 - depth
        gen = generator(soundinfo, note_perform, samplecount, release_sustain: 0.0<bottom)

        -> {
          gen[] * depth + bottom
        }
      end

      def balance_generator(soundinfo, note_perform, samplecount, depth, &block)
        gen = generator(soundinfo, note_perform, samplecount, release_sustain: true)

        -> {
          gen[] * depth
        }
      end

      def plot_data(soundinfo, sustain: 0.0)
        samplecount = soundinfo.window_size.to_f
        note_on = note_on_envelope(soundinfo, samplecount, sustain: false)
        note_off = note_off_envelope(soundinfo, samplecount, sustain: false)
        sustain = AudioStream::Rate.sec(sustain)

        xs = []
        ys = []
        last = nil

        note_on.each {|y|
          xs << xs.length
          ys << y
          last = y
        }

        if last
          sustain_len = (sustain.sample(soundinfo) / samplecount).to_i
          sustain_len.times {|i|
            xs << xs.length
            ys << last
          }
        end

        last = ys.last || 0.0
        note_off.each {|y|
          xs << xs.length
          ys << y * last
        }

        {x: xs, y: ys}
      end

      def plot(soundinfo, sustain: 0.0)
        data = plot_data(soundinfo, sustain: sustain)
        Plotly::Plot.new(data: [data])
      end
    end
  end
end
