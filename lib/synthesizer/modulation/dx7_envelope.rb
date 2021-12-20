require 'synthesizer/modulation/releasable_envelope'

module Synthesizer
  module Modulation
    class Dx7Envelope
      include ReleasableEnvelope

      # 参考
      # OPERATING GUIDE BOOK DIGITAL POLYPHONIC SYNTHESIZER DX7
      # https://jp.yamaha.com/files/download/other_assets/1/316671/DX7J2.pdf

      # @param r1 [AudioStream::Rate | Float] 鍵を押した後LEVEL1までのレベル変化速度 (0~99)
      # @param r2 [AudioStream::Rate | Float] LEVEL1からLEVEL2までのレベル変化速度 (0~99)
      # @param r3 [AudioStream::Rate | Float] LEVEL2からLEVEL3までのレベル変化速度 (0~99)
      # @param r4 [AudioStream::Rate | Float] 鍵を離した後LEVEL4までのレベル変化速度 (0~99)
      # @param l1 [Float] 鍵を弾いた後に達する初期レベル (0~99)
      # @param l2 [Float] LEVEL1とLEVEL3の中間レベル (0~99)
      # @param l3 [Float] 鍵を押さえている間の持続レベル (0~99)
      # @param l4 [Float] 鍵を離した後に戻る基準レベル (0~99)
      def initialize(r1:, r2:, r3:, r4:, l1:, l2:, l3:, l4:)
        @r1 = AudioStream::Rate.dx7(r1)
        @r2 = AudioStream::Rate.dx7(r2)
        @r3 = AudioStream::Rate.dx7(r3)
        @r4 = AudioStream::Rate.dx7(r4)
        @l1 = AudioStream::Decibel.dx7(l1).mag
        @l2 = AudioStream::Decibel.dx7(l2).mag
        @l3 = AudioStream::Decibel.dx7(l3).mag
        @l4 = AudioStream::Decibel.dx7(l4).mag
        @curve = Curve::Straight
      end

      def note_on_envelope(soundinfo, samplecount, sustain: false, &block)
        Enumerator.new do |yld|
          # r1
          r1_len = (@r1.sample(soundinfo) / samplecount).to_i
          r1_len.times {|i|
            x = i.to_f / r1_len
            y = @curve[x] * @l1
            yld << y
          }

          # r2
          r2_len = (@r2.sample(soundinfo) / samplecount).to_i
          l2_diff = @l2 - @l1
          r2_len.times {|i|
            x = i.to_f / r2_len
            y = @curve[x] * l2_diff + @l1
            yld << y
          }

          # r3
          r3_len = (@r3.sample(soundinfo) / samplecount).to_i
          l3_diff = @l3 - @l2
          r3_len.times {|i|
            x = i.to_f / r3_len
            y = @curve[x] * l3_diff + @l2
            yld << y
          }
          yld << @l3

          # sustain
          if sustain
            loop {
              yld << @l3
            }
          end
        end.each(&block)
      end

      def note_off_envelope(soundinfo, samplecount, last_level, sustain: false, &block)
        Enumerator.new do |yld|
          # r4
          r4_len = (@r4.sample(soundinfo) / samplecount).to_i
          l4_diff = @l4 - last_level
          r4_len.times {|i|
            x = i.to_f / r4_len
            y = @curve[x] * l4_diff + last_level
            yld << y
          }
          yld << @l4

          # sustain
          if sustain
            loop {
              yld << @l4
            }
          end
        end.each(&block)
      end


      HARD = Dx7Envelope.new(
        r1: 99, r2: 99, r3: 99, r4: 99,
        l1: 99, l2: 99, l3: 99,  l4: 0
      )
    end
  end
end
