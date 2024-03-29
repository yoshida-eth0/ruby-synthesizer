module Synthesizer
  module Processor
    class High
      def generator(osc, synth, note_perform)
        filter = synth.filter
        amp = synth.amplifier

        soundinfo = synth.soundinfo
        samplecount = synth.soundinfo.window_size.to_f

        # Oscillator, Amplifier
        volume_mod = ModulationValue.amp_generator(soundinfo, note_perform, 1, osc.volume, amp.volume)
        pan_mod = ModulationValue.balance_generator(soundinfo, note_perform, samplecount, osc.pan, amp.pan)
        tune_semis_mod = ModulationValue.balance_generator(soundinfo, note_perform, samplecount, osc.tune_semis, amp.tune_semis, synth.glide&.to_modval)
        tune_cents_mod = ModulationValue.balance_generator(soundinfo, note_perform, samplecount, osc.tune_cents, amp.tune_cents)

        sym_mod = ModulationValue.balance_generator(soundinfo, note_perform, samplecount, osc.sym)
        sync_mod = ModulationValue.balance_generator(soundinfo, note_perform, samplecount, osc.sync)

        uni_num_mod = ModulationValue.balance_generator(soundinfo, note_perform, samplecount, osc.uni_num, amp.uni_num, center: 1.0)
        uni_detune_mod = ModulationValue.balance_generator(soundinfo, note_perform, samplecount, osc.uni_detune, amp.uni_detune)
        uni_stereo_mod = ModulationValue.balance_generator(soundinfo, note_perform, samplecount, osc.uni_stereo, amp.uni_stereo)

        unison = Unison.new(soundinfo, note_perform, osc.source, osc.phase)

        # Filter
        filter_mod = nil
        if filter
          filter_mod = filter.generator(soundinfo, note_perform, samplecount)
        end

        # Frequency modulator
        modulators = osc.freq_modulators.map {|modulator|
          NotePerform.new(modulator, note_perform.note, note_perform.velocity)
        }

        -> {
          # Oscillator, Amplifier
          volume = Vdsp::DoubleArray.create(
            samplecount.to_i.times.map {|i|
              volume_mod[] * note_perform.velocity
            }
          )
          pan = pan_mod[]
          tune_semis = tune_semis_mod[] + synth.pitch_bend
          tune_cents = tune_cents_mod[]

          sym = sym_mod[]
          sync = sync_mod[]

          uni_num = uni_num_mod[]
          uni_detune = uni_detune_mod[]
          uni_stereo = uni_stereo_mod[]

          # Frequency modulator
          modulator_buf = modulators.map {|modulator|
            begin
              modulator.next
            rescue StopIteration => e
              nil
            end
          }.concat.inject(&:+)

          buf = unison.next(uni_num, uni_detune, uni_stereo, volume, pan, tune_semis, tune_cents, sym, sync, osc.carrier_freq, modulator_buf, osc.fm_feedback)

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
