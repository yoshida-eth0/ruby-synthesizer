module Synthesizer
  module OscillatorSource
    class Base
      def initialize
      end

      def next(context, rate, sym, sync, modulator_buf, fm_feedback)
        soundinfo = context.soundinfo
        window_size = context.window_size
        pos = context.pos
        feedback_poses = context.feedback_poses
        hz = rate.freq(soundinfo)

        if modulator_buf
          modulator_stream = modulator_buf.mono.streams[0]

          dst = window_size.times.map {|i|
            hz1 = hz + hz * modulator_stream[i]

            fm_feedback.times {|i|
              hz1 = hz1 + hz1 * sample(context, feedback_poses[i].next(hz1, sym, sync))
            }

            sample(context, pos.next(hz1, sym, sync))
          }
        else
          dst = window_size.times.map {|i|
            hz1 = hz

            fm_feedback.times {|i|
              hz1 = hz1 + hz1 * sample(context, feedback_poses[i].next(hz1, sym, sync))
            }
            #hz1 = hz1 + hz1 * fm_feedback * sample(context, feedback_poses[0].next(hz1, sym, sync))

            sample(context, pos.next(hz1, sym, sync))
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
        attr_reader :feedback_poses

        def initialize(soundinfo, note_perform, init_phase)
          @soundinfo = soundinfo
          @note_perform = note_perform
          @init_phase = init_phase
          @pos = ShapePos.new(@soundinfo.samplerate, init_phase)
          @feedback_poses = 7.times.map {
            @pos.dup
          }
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
