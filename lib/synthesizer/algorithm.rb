require 'set'

module Synthesizer
  class Algorithm
    attr_reader :route

    def initialize(route={})
      @route = {}
    end

    def add(*operators)
      (operators.length - 1).times {|i|
        _add(operators[i], operators[i+1])
      }
      self
    end

    def _add(modulators, carriers)
      modulators = [modulators].flatten
      carriers = [carriers].flatten

      modulators.each {|modulator|
        carriers.each {|carrier|
          @route[carrier] ||= Set.new
          @route[carrier] << modulator
        }
      }
      self
    end

    def modulator_ids
      @route.values.map(&:to_a).flatten.uniq
    end
  end
end
