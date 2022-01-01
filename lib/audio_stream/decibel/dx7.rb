module AudioStream
  class Decibel
    def self.dx7(v)
      if self===v
        v
      else
        new(mag: v / 99.0)
      end
    end
  end
end
