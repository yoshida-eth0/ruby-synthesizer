module Synthesizer
  module Processor
    class High
      def generator(osc, note_perform)
        synth = note_perform.synth
        filter = synth.filter
        amp = synth.amplifier
        channels = synth.soundinfo.channels
        window_size = synth.soundinfo.window_size
        framerate = synth.soundinfo.samplerate.to_f

        # Oscillator, Amplifier
        volume_mod = ModulationValue.amp_generator(note_perform, framerate, osc.volume, amp.volume)
        pan_mod = ModulationValue.balance_generator(note_perform, framerate, osc.pan, amp.pan)
        tune_semis_mod = ModulationValue.balance_generator(note_perform, framerate, osc.tune_semis, amp.tune_semis, synth.glide&.to_modval)
        tune_cents_mod = ModulationValue.balance_generator(note_perform, framerate, osc.tune_cents, amp.tune_cents)

        uni_num_mod = ModulationValue.balance_generator(note_perform, framerate, osc.uni_num, amp.uni_num, center: 1.0)
        uni_detune_mod = ModulationValue.balance_generator(note_perform, framerate, osc.uni_detune, amp.uni_detune)
        unison = Unison.new(note_perform, osc.shape, osc.phase)

        # Filter
        filter_mod = nil
        if filter
          filter_mod = filter.generator(note_perform, framerate / window_size)
        end

        case channels
        when 1
          -> {
            buf = AudioStream::Buffer.create_mono(window_size)
            dst0 = buf.streams[0]

            window_size.times.each {|i|
              # Oscillator, Amplifier
              volume = volume_mod[] * note_perform.velocity
              tune_semis = tune_semis_mod[] + synth.pitch_bend
              tune_cents = tune_cents_mod[]

              uni_num = uni_num_mod[]
              uni_detune = uni_detune_mod[]

              sval = unison.next(uni_num, uni_detune, volume, 0.0, tune_semis, tune_cents)
              mval = (sval[0] + sval[1]) / 2.0

              dst0[i] = mval
            }

            # Filter
            if filter_mod
              filter_fx = filter_mod[]
              buf = filter_fx.process(buf)
            end

            buf
          }
        when 2
          -> {
            buf = AudioStream::Buffer.create_stereo(window_size)
            dst0 = buf.streams[0]
            dst1 = buf.streams[1]

            window_size.times.each {|i|
              # Oscillator, Amplifier
              volume = volume_mod[] * note_perform.velocity
              pan = pan_mod[]
              tune_semis = tune_semis_mod[] + synth.pitch_bend
              tune_cents = tune_cents_mod[]

              uni_num = uni_num_mod[]
              uni_detune = uni_detune_mod[]

              sval = unison.next(uni_num, uni_detune, volume, pan, tune_semis, tune_cents)

              dst0[i] = sval[0]
              dst1[i] = sval[1]
            }

            # Filter
            if filter_mod
              filter_fx = filter_mod[]
              buf = filter_fx.process(buf)
            end

            buf
          }
        end
      end
    end
  end
end
