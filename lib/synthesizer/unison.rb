module Synthesizer
  class Unison
    UNI_NUM_MAX = 16

    def initialize(soundinfo, note_perform, source, phase)
      @soundinfo = soundinfo
      @note_perform = note_perform
      @source = source
      @source_contexts = UNI_NUM_MAX.times.map {|i|
        source.generate_context(soundinfo, note_perform,  phase.value)
      }
    end

    def next(uni_num, uni_detune, uni_stereo, volume, pan, tune_semis, tune_cents, sym, sync, carrier_freq, modulator_buf, fm_feedback)
      if uni_num<1.0
        uni_num = 1.0
      elsif UNI_NUM_MAX<uni_num
        uni_num = UNI_NUM_MAX
      end

      if uni_num==1.0
        context = @source_contexts[0]

        l_gain, r_gain = Utils.panning(pan)
        freq = carrier_freq.freq(@soundinfo, @note_perform.note, semis: tune_semis, cents: tune_cents)

        stream = @source.next(context, freq, sym, sync, modulator_buf, fm_feedback)
        AudioStream::Buffer.new(stream * (l_gain * volume), stream * (r_gain * volume))
      else
        buffer = uni_num.ceil.times.map {|i|
          context = @source_contexts[i]

          uni_volume = 1.0
          if uni_num<i
            uni_volume = uni_num % 1.0
          end

          sign = i.even? ? 1 : -1
          diff = sign * (i + 1.0) / (uni_num + 1.0)

          detune_cents = uni_detune * diff * 100
          diff_pan = uni_stereo * diff

          l_gain, r_gain = Utils.panning(pan + diff_pan)
          freq = carrier_freq.freq(@soundinfo, @note_perform.note, semis: tune_semis, cents: tune_cents + detune_cents)

          stream = @source.next(context, freq, sym, sync, modulator_buf, fm_feedback)
          AudioStream::Buffer.new(stream * (l_gain * uni_volume / uni_num * volume), stream * (r_gain * uni_volume / uni_num * volume))
        }.inject(:+)
      end
    end
  end
end
