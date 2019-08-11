module AudioStream
  class AudioInputSynth
    include AudioInput

    def initialize(synth, soundinfo:)
      super()

      @synth = synth
      @soundinfo = soundinfo
    end

    def connect
      self
    end

    def disconnect
      self
    end

    def connected?
      true
    end

    def each(&block)
      Enumerator.new do |y|
        loop {
          buf = @synth.next
          y << buf
        }
      end.each(&block)
    end
  end
end
