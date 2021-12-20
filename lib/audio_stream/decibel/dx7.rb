module AudioStream
  class Decibel
    def self.dx7(v)
      if self===v
        v
      else
        new(mag: v / 99.0)
      end
    end

    def self.dx7_pitch(v)
      if self===v
        v
      else
        new(mag: (v - 50.0) / 32.0 * 12.0)
      end
    end
  end
end
