module AudioStream
  class AudioInputStepEditor < Rx::Subject
    include AudioInput

    def initialize(synth, step_editor)
      super()

      @synth = synth
      @step_editor = step_editor

      @soundinfo = synth.soundinfo
    end

    def each(&block)
      Enumerator.new do |y|
        events = Hash.new {|h, k| h[k]=[]}

        fps = @soundinfo.samplerate.to_f / @soundinfo.window_size
        @step_editor.events.each {|event|
          pos = event[0]
          events[(pos * fps).to_i] << event
        }

        catch :break do
          Range.new(0, nil).each {|i|
            if events.has_key?(i)
              events[i].sort{|a,b| a[0]<=>b[0]}.each {|event|
                type = event[1]

                case type
                when :note_on
                  @synth.note_on(event[2], velocity: event[3])
                when :note_off
                  @synth.note_off(event[2])
                when :pitch_bend
                  @synth.pitch_bend = event[2]
                when :complete
                  throw :break
                end
              }
            end

            buf = @synth.next
            y << buf
          }
        end
      end.each(&block)
    end
  end
end
