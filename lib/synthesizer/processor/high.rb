module Synthesizer
  module Processor
    class High
      def generator(osc, note_perform, &block)
        Enumerator.new do |y|
          synth = note_perform.synth
          filter = synth.filter
          amp = synth.amplifier
          channels = synth.soundinfo.channels
          window_size = synth.soundinfo.window_size
          framerate = synth.soundinfo.samplerate

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
            filter_mod = filter.generator(note_perform, framerate)
          end

          case channels
          when 1
            loop {
              buf = AudioStream::Buffer.float(window_size, channels)

              window_size.times.each {|i|
                # Oscillator, Amplifier
                volume = volume_mod.next * note_perform.velocity
                tune_semis = tune_semis_mod.next + synth.pitch_bend
                tune_cents = tune_cents_mod.next

                uni_num = uni_num_mod.next
                uni_detune = uni_detune_mod.next

                sval = unison.next(uni_num, uni_detune, volume, 0.0, tune_semis, tune_cents)
                mval = (sval[0] + sval[1]) / 2.0

                # Filter
                if filter_mod
                  filter_fx = filter_mod.next
                  mval = filter_fx.process_mono(mval)
                end

                buf[i] = mval
              }

              y << buf
            }
          when 2
            loop {
              buf = AudioStream::Buffer.float(window_size, channels)

              window_size.times.each {|i|
                # Oscillator, Amplifier
                volume = volume_mod.next * note_perform.velocity
                pan = pan_mod.next
                tune_semis = tune_semis_mod.next + synth.pitch_bend
                tune_cents = tune_cents_mod.next

                uni_num = uni_num_mod.next
                uni_detune = uni_detune_mod.next

                sval = unison.next(uni_num, uni_detune, volume, pan, tune_semis, tune_cents)

                # Filter
                if filter_mod
                  filter_fx = filter_mod.next
                  sval = filter_fx.process_stereo(sval)
                end

                buf[i] = sval
              }

              y << buf
            }
          end
        end.each(&block)
      end
    end
  end
end
