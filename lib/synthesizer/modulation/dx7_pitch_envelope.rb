module Synthesizer
  module Modulation
    class Dx7PitchEnvelope < Dx7Envelope

      # @param r1 [AudioStream::Rate | Float] 鍵を押した後LEVEL1までのレベル変化速度 (0~99)
      # @param r2 [AudioStream::Rate | Float] LEVEL1からLEVEL2までのレベル変化速度 (0~99)
      # @param r3 [AudioStream::Rate | Float] LEVEL2からLEVEL3までのレベル変化速度 (0~99)
      # @param r4 [AudioStream::Rate | Float] 鍵を離した後LEVEL4までのレベル変化速度 (0~99)
      # @param l1 [Float] 鍵を弾いた後に達する初期ピッチ. 1octave=32, center=50 (0~99)
      # @param l2 [Float] LEVEL1とLEVEL3の中間ピッチ. 1octave=32, center=50 (0~99)
      # @param l3 [Float] 鍵を押さえている間の持続ピッチ. 1octave=32, center=50 (0~99)
      # @param l4 [Float] 鍵を弾いた初期ピッチと鍵を離した後に戻る基準ピッチ. 1octave=32, center=50 (0~99)
      def initialize(r1:, r2:, r3:, r4:, l1:, l2:, l3:, l4:)
        @rates = [r1.to_i, r2.to_i, r3.to_i, r4.to_i]
        @levels = [l1.to_i, l2.to_i, l3.to_i, l4.to_i]
      end

      def create_context(soundinfo, samplecount)
        Context.new(soundinfo, samplecount, @rates, @levels)
      end

      def plot(soundinfo, sustain: 0.0)
        data = plot_data(soundinfo, sustain: sustain)
        Plotly::Plot.new(data: [data])
      end


      # PitchEnv by Google Inc used with modifications under Apache License, Version 2.0.
      # Copyright (c) 2012 Google Inc
      # https://github.com/google/music-synthesizer-for-android/blob/master/app/src/main/jni/pitchenv.cc

      class Context
        @@ratetab = [
          1, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9, 10, 10, 11, 11, 12,
          12, 13, 13, 14, 14, 15, 16, 16, 17, 18, 18, 19, 20, 21, 22, 23, 24,
          25, 26, 27, 28, 30, 31, 33, 34, 36, 37, 38, 39, 41, 42, 44, 46, 47,
          49, 51, 53, 54, 56, 58, 60, 62, 64, 66, 68, 70, 72, 74, 76, 79, 82,
          85, 88, 91, 94, 98, 102, 106, 110, 115, 120, 125, 130, 135, 141, 147,
          153, 159, 165, 171, 178, 185, 193, 202, 211, 232, 243, 254, 255
        ]

        @@pitchtab = [
          -128, -116, -104, -95, -85, -76, -68, -61, -56, -52, -49, -46, -43,
          -41, -39, -37, -35, -33, -32, -31, -30, -29, -28, -27, -26, -25, -24,
          -23, -22, -21, -20, -19, -18, -17, -16, -15, -14, -13, -12, -11, -10,
          -9, -8, -7, -6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
          11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27,
          28, 29, 30, 31, 32, 33, 34, 35, 38, 40, 43, 46, 49, 53, 58, 65, 73,
          82, 92, 103, 115, 127
        ]

        attr_reader :state

        def initialize(soundinfo, samplecount, rates, levels)
          @samplescale = 44100.0 * (1 << 24) / (21.3 * soundinfo.samplerate) + 0.5
          @samplescale = @samplescale * 1024 / samplecount
          @rates = rates
          @levels = levels

          @state = nil
          @targetlevel = 0
          @rising = false
          @level = @@pitchtab[levels.last] << 19

          advance(0)
        end

        def render(note_on)
          if @state < 3 || (@state < 4 && !note_on)
            if @rising
              @level += @inc;
              if @level >= @targetlevel
                @level = @targetlevel
                advance(@state + 1)
              end
            else
              @level -= @inc
              if @level <= @targetlevel
                @level = @targetlevel
                advance(@state + 1)
              end
            end
          end
          @level / 32767.0
        end

        def advance(newstate)
          @state = newstate
          if @state < 4
            newlevel = @levels[newstate]
            @targetlevel = @@pitchtab[newlevel] << 19
            @rising = @targetlevel > @level
            @inc = @@ratetab[@rates[newstate]] * @samplescale
          end
        end
      end


      KEEP = Dx7PitchEnvelope.new(
        r1: 99,
        r2: 99,
        r3: 99,
        r4: 99,
        l1: 50,
        l2: 50,
        l3: 50,
        l4: 50
      )
    end
  end
end
