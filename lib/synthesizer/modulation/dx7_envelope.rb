module Synthesizer
  module Modulation
    class Dx7Envelope
      include AmpEnvelope

      # 参考
      # OPERATING GUIDE BOOK DIGITAL POLYPHONIC SYNTHESIZER DX7
      # https://jp.yamaha.com/files/download/other_assets/1/316671/DX7J2.pdf

      # @param r1 [Integer] 鍵を押した後LEVEL1までのレベル変化速度 (0~99)
      # @param r2 [Integer] LEVEL1からLEVEL2までのレベル変化速度 (0~99)
      # @param r3 [Integer] LEVEL2からLEVEL3までのレベル変化速度 (0~99)
      # @param r4 [Integer] 鍵を離した後LEVEL4までのレベル変化速度 (0~99)
      # @param l1 [Integer] 鍵を弾いた後に達する初期レベル (0~99)
      # @param l2 [Integer] LEVEL1とLEVEL3の中間レベル (0~99)
      # @param l3 [Integer] 鍵を押さえている間の持続レベル (0~99)
      # @param l4 [Integer] 鍵を離した後に戻る基準レベル (0~99)
      def initialize(r1:, r2:, r3:, r4:, l1:, l2:, l3:, l4:)
        @rates = [r1.to_i, r2.to_i, r3.to_i, r4.to_i]
        @levels = [l1.to_i, l2.to_i, l3.to_i, l4.to_i]
      end

      def note_on_envelope(soundinfo, samplecount, ctx, sustain: false, &block)
        Enumerator.new do |yld|
          while ctx.state < 3
            yld << ctx.render(true)
          end

          # sustain
          if sustain
            loop {
              yld << ctx.render(true)
            }
          end
        end.each(&block)
      end

      def note_off_envelope(soundinfo, samplecount, ctx, sustain: false, &block)
        Enumerator.new do |yld|
          ctx.advance(3)

          while ctx.state < 4
            yld << ctx.render(false)
          end

          # sustain
          if sustain
            loop {
              yld << ctx.render(false)
            }
          end
        end.each(&block)
      end

      def create_context(soundinfo)
        Context.new(soundinfo, @rates, @levels)
      end

      def generator(soundinfo, note_perform, samplecount, release_sustain:)
        ctx = create_context(soundinfo)
        note_on = note_on_envelope(soundinfo, samplecount, ctx, sustain: true)
        note_off = note_off_envelope(soundinfo, samplecount, ctx, sustain: release_sustain)

        -> {
          if note_perform.note_on?
            note_on.next
          else
            note_off.next
          end
        }
      end

      def plot_data(soundinfo, sustain: 0.0)
        samplecount = soundinfo.window_size.to_f
        ctx = create_context(soundinfo)
        note_on = note_on_envelope(soundinfo, samplecount, ctx, sustain: false)
        sustain = AudioStream::Rate.sec(sustain)

        xs = []
        ys = []

        note_on.each {|y|
          xs << xs.length
          ys << y
        }

        sustain_len = (sustain.sample(soundinfo) / samplecount).to_i
        sustain_len.times {|i|
          xs << xs.length
          ys << ctx.render(true)
        }

        note_off = note_off_envelope(soundinfo, samplecount, ctx, sustain: false)
        note_off.each {|y|
          xs << xs.length
          ys << y
        }

        {x: xs, y: ys}
      end

      def plot(soundinfo, sustain: 0.0)
        data = plot_data(soundinfo, sustain: sustain)
        Plotly::Plot.new(data: [data], layout: {yaxis: {type: 'log'}})
      end


      # EnvelopeDX7 by Matt Montag used with modifications under MIT license.
      # Copyright (c) 2014 Matt Montag
      # https://github.com/mmontag/dx7-synth-js/blob/master/src/envelope-dx7.js

      class Context
        @@outputlevel = [0, 5, 9, 13, 17, 20, 23, 25, 27, 29, 31, 33, 35, 37, 39,
          41, 42, 43, 45, 46, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61,
          62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80,
          81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99,
          100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114,
          115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127];

        @@output_lut = 4096.times.map {|i|
          db = (i - 3824) * 0.0235
          20 ** (db / 20)
        }

        attr_reader :state

        def initialize(soundinfo, rates, levels)
          @samplescale = 44100.0 / soundinfo.samplerate * 0.5
          @rates = rates
          @levels = levels

          @state = nil
          @targetlevel = 0
          @rising = false
          @level = 0
          @decayIncrement = 0

          advance(0)
        end

        def render(note_on)
          if @state < 3 || @state<4 && !note_on
            lev = @level
            if @rising
              lev += @decayIncrement * (2 + (@targetlevel - lev) / 256);
              if @targetlevel <= lev
                lev = @targetlevel
                advance(@state + 1);
              end
            else
              lev -= @decayIncrement
              if lev <= @targetlevel
                lev = @targetlevel
                advance(@state + 1);
              end
            end
            @level = lev
          end
          @@output_lut[@level.floor]
        end

        def advance(newstate)
          @state = newstate
          if @state < 4
            newlevel = @levels[newstate]
            @targetlevel = [0, (@@outputlevel[newlevel] << 5) - 224].max
            @rising = (@targetlevel - @level) > 0
            qr = [63, ((@rates[@state] * 41) >> 6)].min
            @decayIncrement = (2 ** (qr/4.0)) * @samplescale
          end
        end
      end


      HARD = Dx7Envelope.new(
        r1: 99, r2: 99, r3: 99, r4: 99,
        l1: 99, l2: 99, l3: 99,  l4: 0
      )
    end
  end
end
