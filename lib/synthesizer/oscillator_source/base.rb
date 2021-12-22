module Synthesizer
  module OscillatorSource
    class Base
      def initialize
      end

      def next(context, rate, sym, sync, modulator_buf, fm_feedback)
        soundinfo = context.soundinfo
        window_size = context.window_size
        pos = context.pos
        hz = rate.freq(soundinfo)

        # TODO feedback

        if modulator_buf
          modulator_stream = modulator_buf.mono.streams[0]
          dst = window_size.times.map {|i|
            sample(context, pos.next(hz + hz * modulator_stream[i], sym, sync))
          }
        else
          dst = window_size.times.map {|i|
            sample(context, pos.next(hz, sym, sync))
          }
        end

        Vdsp::DoubleArray.create(dst)
      end

      def sample(context, phase)
        raise Error, "not implemented abstruct method: #{self.class.name}.sample(context, phase)"
      end

      def generate_context(soundinfo, note_perform, init_phase)
        Context.new(soundinfo, note_perform, init_phase)
      end

      class Context
        attr_reader :soundinfo
        attr_reader :note_perform
        attr_reader :init_phase
        attr_reader :pos

        def initialize(soundinfo, note_perform, init_phase)
          @soundinfo = soundinfo
          @note_perform = note_perform
          @init_phase = init_phase
          @pos = ShapePos.new(@soundinfo.samplerate, init_phase)
        end

        def window_size
          @window_size ||= soundinfo.window_size
        end

        def samplerate
          @samplerate ||= soundinfo.samplerate
        end

        def framerate
          @framerate ||= soundinfo.framerate
        end
      end
    end
  end
end
