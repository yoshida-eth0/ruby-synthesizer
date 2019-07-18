module Synthesizer
  module Processor
    class Low
      def generator(osc, note_perform, &block)
        Enumerator.new do |y|
          synth = note_perform.synth
          filter = synth.filter
          amp = synth.amplifier
          channels = synth.soundinfo.channels
          window_size = synth.soundinfo.window_size
          framerate = synth.soundinfo.samplerate.to_f / window_size

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

              volume = volume_mod.next
              tune_semis = tune_semis_mod.next + synth.pitch_bend
              tune_cents = tune_cents_mod.next

              uni_num = uni_num_mod.next
              uni_detune = uni_detune_mod.next

              window_size.times.each {|i|
                val = unison.next(uni_num, uni_detune, volume, 0.0, tune_semis, tune_cents)
                buf[i] = (val[0] + val[1]) / 2.0
              }

              y << buf
            }
          when 2
            loop {
              buf = AudioStream::Buffer.float(window_size, channels)

              # Oscillator, Amplifier
              volume = volume_mod.next
              pan = pan_mod.next
              tune_semis = tune_semis_mod.next + synth.pitch_bend
              tune_cents = tune_cents_mod.next

              uni_num = uni_num_mod.next
              uni_detune = uni_detune_mod.next

              window_size.times.each {|i|
                buf[i] = unison.next(uni_num, uni_detune, volume, pan, tune_semis, tune_cents)
              }

              # Filter
              if filter_mod
                filter_fx = filter_mod.next
                buf = filter_fx.process(buf)
              end

              y << buf
            }
          end
        end.each(&block)
      end
    end
  end
end
