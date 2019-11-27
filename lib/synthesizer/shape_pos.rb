module Synthesizer
  class ShapePos
    def initialize(init_phase: 0.0)
      @init_phase = init_phase

      @offset = 0
      @phase = 0.0
    end

    def next(delta, sym, sync)
      @offset += 1

      if @offset==1
        if @init_phase
          @phase = @init_phase + delta
        else
          @phase = Random.rand + delta
        end
      # TODO: sync
      #elsif @sync && @sync<@offset
      #  @offset = 0
      #  @phase = @init_phase
      else
        @phase += delta
      end
    end
  end
end
