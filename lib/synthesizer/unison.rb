module Synthesizer
  class Unison
    UNI_NUM_MAX = 16

    def initialize(note_perform, source, phase)
      synth = note_perform.synth
      @samplerate = synth.soundinfo.samplerate

      @note_perform = note_perform
      @source = source
      @source_contexts = UNI_NUM_MAX.times.map {|i|
        source.generate_context(synth.soundinfo, note_perform,  phase.value)
      }
    end

    def next(uni_num, uni_detune, volume, pan, tune_semis, tune_cents)
      if uni_num<1.0
        uni_num = 1.0
      elsif UNI_NUM_MAX<uni_num
        uni_num = UNI_NUM_MAX
      end

      uni_num.ceil.times.map {|i|
        context = @source_contexts[i]

        uni_volume = 1.0
        if uni_num<i
          uni_volume = uni_num % 1.0
        end

        sign = i.even? ? 1 : -1
        detune_cents = sign * (i/2) * uni_detune * 100
        diff_pan = sign * (i/2) * uni_detune

        l_gain, r_gain = Utils.panning(pan + diff_pan)

        hz = @note_perform.note.hz(semis: tune_semis, cents: tune_cents + detune_cents)
        delta = hz / @samplerate

        @source.next(context, delta, l_gain * volume * uni_volume / uni_num, r_gain * volume * uni_volume / uni_num)
      }.inject(:+)
    end
  end
end
