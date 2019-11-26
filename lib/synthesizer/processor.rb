module Synthesizer
  class Processor
    def generator(osc, note_perform)
      synth = note_perform.synth
      filter = synth.filter
      amp = synth.amplifier
      window_size = synth.soundinfo.window_size
      framerate = synth.soundinfo.samplerate.to_f / window_size

      # Oscillator, Amplifier
      volume_mod = ModulationValue.amp_generator(note_perform, framerate, osc.volume, amp.volume)
      pan_mod = ModulationValue.balance_generator(note_perform, framerate, osc.pan, amp.pan)
      tune_semis_mod = ModulationValue.balance_generator(note_perform, framerate, osc.tune_semis, amp.tune_semis, synth.glide&.to_modval)
      tune_cents_mod = ModulationValue.balance_generator(note_perform, framerate, osc.tune_cents, amp.tune_cents)

      uni_num_mod = ModulationValue.balance_generator(note_perform, framerate, osc.uni_num, amp.uni_num, center: 1.0)
      uni_detune_mod = ModulationValue.balance_generator(note_perform, framerate, osc.uni_detune, amp.uni_detune)
      uni_stereo_mod = ModulationValue.balance_generator(note_perform, framerate, osc.uni_stereo, amp.uni_stereo)
      unison = Unison.new(note_perform, osc.source, osc.phase)

      # Filter
      filter_mod = nil
      if filter
        filter_mod = filter.generator(note_perform, framerate)
      end

      -> {
        # Oscillator, Amplifier
        volume = volume_mod[] * note_perform.velocity
        pan = pan_mod[]
        tune_semis = tune_semis_mod[] + synth.pitch_bend
        tune_cents = tune_cents_mod[]

        uni_num = uni_num_mod[]
        uni_detune = uni_detune_mod[]
        uni_stereo = uni_stereo_mod[]

        buf = unison.next(uni_num, uni_detune, uni_stereo, volume, pan, tune_semis, tune_cents)

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
