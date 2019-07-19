module Synthesizer
  class Note
    NOTE_TABLE = [:"C", :"C#/Db", :"D", :"D#/Eb", :"E", :"F", :"F#/Gb", :"G", :"G#/Ab", :"A", :"A#/Bb", :"B"].freeze
    NOTE_NAME_TABLE = {
      :"C" => 0,
      :"C#/Db" => 1,
      :"C#" => 1,
      :"Db" => 1,
      :"D" =>  2,
      :"D#/Eb" => 3,
      :"D#" => 3,
      :"Eb" => 3,
      :"E" => 4,
      :"F" => 5,
      :"F#/Gb" => 6,
      :"F#" => 6,
      :"Gb" => 6,
      :"G" => 7,
      :"G#/Ab" => 8,
      :"G#" => 8,
      :"Ab" => 8,
      :"A" => 9,
      :"A#/Bb" => 10,
      :"A#" => 10,
      :"Bb" => 10,
      :"B" => 11
    }.freeze

    attr_reader :num

    def initialize(num)
      @num = num.to_i
    end

    def hz(semis: 0, cents: 0)
      6.875 * (2 ** ((@num + semis + (cents / 100.0) + 3) / 12.0))
    end

    def note_name
      NOTE_TABLE[@num % 12]
    end

    def octave_num
      (@num / 12) - 1
    end

    def self.create(name, octave)
      name = name.to_sym
      octave = octave.to_i

      note_index = NOTE_NAME_TABLE[name]
      if !note_index
        raise Error, "not found note name: #{name}"
      end

      num = (octave + 1) * 12 + note_index
      if num<0
        raise Error, "octave #{octave} outside of note"
      end

      new(num)
    end
  end
end
