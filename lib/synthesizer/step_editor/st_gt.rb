module Synthesizer
  module StepEditor
    class StGt

      attr_reader :ppq
      attr_reader :events

      def initialize(bpm:, ppq: 480, &block)
        @ppq = ppq
        @seek = 0.0
        @location = 0
        @events = []
        self.bpm = bpm

        if block_given?
          yield self
        end
      end

      def bpm=(bpm)
        @ppq_rate = 60.0 / (@ppq.to_f * bpm)
      end

      def step(st)
        @location += st
        @seek += st * @ppq_rate
      end

      def location(beats: 4)
        tick = @location % @ppq
        location = (@location - tick) / @ppq
        beat = location % beats
        location = location - beat
        measure = location / beats

        "#{measure+1}. #{beat+1}. #{tick}"
      end

      def note(note, st: 0, gt:, vel: 1.0, dev: 0)
        @events << [@seek + dev * @ppq_rate, :note_on, note, vel]
        @events << [@seek + (gt + dev) * @ppq_rate, :note_off, note]
        step(st)
      end

      def pitch_bend(semis, st: 0, dev: 0)
        @events << [@seek + dev * @ppq_rate, :pitch_bend, semis]
        step(st)
      end

      def complete
        @events << [@seek, :complete]
      end
    end
  end
end
