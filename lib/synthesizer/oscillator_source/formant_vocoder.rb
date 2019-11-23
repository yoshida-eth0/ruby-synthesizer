module Synthesizer
  module OscillatorSource
    class FormantVocoder
      attr_reader :vowels
      attr_reader :pronunciation

      @@f = {
        i: [110.0, 250.0, 2100.0, 2900.0, 3700.0],
        e: [160.0, 450.0, 1900.0, 2650.0, 3800.0],
        a: [110.0, 700.0, 1250.0, 2500.0, 3900.0],
        o: [110.0, 500.0, 1050.0, 2700.0, 3700.0],
        u: [110.0, 330.0, 1500.0, 2400.0, 3650.0],
        x: [110.0, 335.0, 1550.0, 2450.0, 3800.0],
      }
      @@gain = [50.0, 70.0, 110.0, 200.0, 200.0].map {|x| Math::PI * x}

      def initialize(vowels: [:i, :e, :a, :o, :u], pronunciation: 0)
        self.vowels = vowels
        self.pronunciation = pronunciation
        @pulse = Pulse.instance
      end

      def vowels=(vowels)
        vowels = vowels + [vowels[0]]
        @vowels = vowels.map {|v| @@f[v]}
        @vowels_len = @vowels.length
      end

      def pronunciation=(pronunciation)
        @pronunciation = ModulationValue.create(pronunciation)
      end

      def next(context, delta, l_gain, r_gain)
        channels = context.channels
        window_size = context.window_size
        samplerate = context.samplerate
        tmpbufs = context.tmpbufs
        pronunciation_mod = context.pronunciation_mod

        @pulse_context ||= @pulse.generate_context(context.soundinfo, context.note_perform, context.phase)
        pulse = @pulse.next(@pulse_context, delta, 0.5, 0.5).streams[0]

        r_index = pronunciation_mod[]
        index = r_index.to_i

        dst = 5.times.map {|i|
        #dst = (1...5).each.map {|i|
          tmpbuf = tmpbufs[i]
          freq = @vowels[index % @vowels_len][i]+(@vowels[(index+1) % @vowels_len][i]-@vowels[index % @vowels_len][i])*(r_index-index)
          w = Math::PI * 2 * freq
          resfil(pulse, tmpbufs[i], @@gain[i], w, 1.0/samplerate, window_size)
        }.inject(:+)

        case channels
        when 1
          Buffer.new(dst * l_gain)
        when 2
          Buffer.new(dst * l_gain, dst * r_gain)
        end
      end

      def resfil(x, v, a, w, dt, len)
        b = 2.0 * (Math::E ** (-a*dt)) * Math.cos(w*dt)
        c = Math::E ** (-2.0 * a * dt)
        d = ((a*a+w*w)/w) * (Math::E ** (-a*dt)) * Math.sin(w*dt)

        #v[0] = v[len-2]
        #v[1] = v[len-1]
        #v[0] += 1.0

        #Vdsp::UnsafeDouble.vsmsma(v, 1, 1, b, v, 0, 1, -c, v, 2, 1, len)
        #v * (d / 25000.to_f)

        v[0] = v[len-2]
        v[1] = v[len-1]

        y = len.times.map {|i|
          v[i+2] = b * v[i+1] - c * v[i] + x[i]
          v[i+1] * (d / 25000.to_f)
        }

        Vdsp::DoubleArray.create(y)
      end

      def generate_context(soundinfo, note_perform, phase)
        pronunciation_mod = ModulationValue.balance_generator(note_perform, soundinfo.framerate, @pronunciation)
        tmpbufs = Array.new(5) {|i| Vdsp::DoubleArray.new(soundinfo.window_size+2)}

        FvContext.new(soundinfo, note_perform, phase, tmpbufs, pronunciation_mod)
      end

      FvContext = Struct.new("FvContext", :soundinfo, :note_perform, :phase, :tmpbufs, :pronunciation_mod) do
        def window_size
          soundinfo.window_size
        end

        def channels
          soundinfo.channels
        end

        def samplerate
          soundinfo.samplerate
        end
      end
    end
  end
end
