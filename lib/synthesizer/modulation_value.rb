module Synthesizer
  class ModulationValue

    attr_accessor :value
    attr_reader :mods

    def initialize(value, mods={})
      @value = value
      @mods = []

      mods.each {|mod, depth|
        add(mod, depth: depth || 1.0)
      }
    end

    # @param mod [Synthesizer::Modulation]
    # @param depth [Float] depth. volume => percent(-1.0~1.0, default=1.0), filter freq => relative value(hz), other => relative value
    def add(mod, depth: 1.0)
      depth ||= 1.0
      #if depth<-1.0
      #  depth = -1.0
      #elsif 1.0<depth
      #  depth = 1.0
      #end

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

    def self.amp_generator(note_perform, samplecount, *modvals)
      modvals = modvals.flatten.compact

      # value
      value = modvals.map(&:value).sum

      # mods
      mods = []
      modvals.each {|modval|
        modval.mods.each {|mod, depth|
          mods << mod.amp_generator(note_perform, samplecount, depth)
        }
      }

      -> {
        depth = mods.map(&:[]).inject(1.0, &:*)
        value * depth
      }
    end

    def self.balance_generator(note_perform, samplecount, *modvals, center: 0)
      modvals = modvals.flatten.compact

      # value
      value = modvals.map(&:value).sum
      value -= (modvals.length - 1) * center

      # mods
      mods = []
      modvals.each {|modval|
        modval.mods.each {|mod, depth|
          mods << mod.balance_generator(note_perform, samplecount, depth)
        }
      }

      -> {
        depth = mods.map(&:[]).sum
        value + depth
      }
    end
  end
end
