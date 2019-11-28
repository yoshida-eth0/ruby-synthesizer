module Synthesizer
  class ShapePos
    SEMITONE_RATIO = 2.0 ** (1.0 / 12.0)

    def initialize(samplerate, init_phase)
      @samplerate = samplerate.to_f

      init_phase = init_phase ? init_phase.to_f : Random.rand(1.0)
      @sync_phase = init_phase
      @shape_phase = init_phase
    end

    def next(hz, sym, sync)
      if sync<0.0
        sync = 0.0
      end

      if 1.0<=@sync_phase
        @sync_phase %= 1.0
        @shape_phase = @sync_phase
      end

      sync_hz = hz
      sync_delta = sync_hz / @samplerate
      @sync_phase += sync_delta

      shape_hz = hz * (SEMITONE_RATIO ** sync)
      shape_delta = shape_hz / @samplerate
      @shape_phase += shape_delta
    end
  end
end
