module Synthesizer
  class ModulationValue

    attr_accessor :value
    attr_reader :mods

    def initialize(value, mods={})
      @value = value
      @mods = []

      mods.each {|mod, depth|
        add(mod, depth: depth)
      }
    end

    # @param mod [Synthesizer::Modulation]
    # @param depth [Float] (-1.0~1.0)
    def add(mod, depth: 1.0)
      depth ||= 1.0
      if depth<-1.0
        depth = -1.0
      elsif 1.0<depth
        depth = 1.0
      end

      @mods << [mod, depth]
      self
    end

    def self.create(value)
      if ModulationValue===value
        value
      else
        new(value)
      end
    end

    def self.amp_generator(note_perform, samplerate, *modvals)
      modvals = modvals.flatten.compact

      # value
      value = modvals.map(&:value).sum

      # mods
      mods = []
      modvals.each {|modval|
        modval.mods.each {|mod, depth|
          mods << mod.amp_generator(note_perform, samplerate, depth)
        }
      }

      Enumerator.new do |y|
        loop {
          depth = mods.map(&:next).inject(1.0, &:*)
          y << value * depth
        }
      end
    end

    def self.balance_generator(note_perform, samplerate, *modvals, center: 0)
      modvals = modvals.flatten.compact

      # value
      value = modvals.map(&:value).sum
      value -= (modvals.length - 1) * center

      # mods
      mods = []
      modvals.each {|modval|
        modval.mods.each {|mod, depth|
          mods << mod.balance_generator(note_perform, samplerate, depth)
        }
      }

      Enumerator.new do |y|
        loop {
          depth = mods.map(&:next).sum
          y << value + depth
        }
      end
    end
  end
end
