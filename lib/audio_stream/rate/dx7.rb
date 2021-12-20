module AudioStream
  class Rate
    def self.dx7(v)
      if self===v
        v   
      else
        # NOTE: approximation, unknown formula
        new(freq: Math.exp(v / 9.0) / 42.0)
      end 
    end 
  end
end
