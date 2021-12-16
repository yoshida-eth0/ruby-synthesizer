require 'synthesizer/freq/base'

module Synthesizer
  module Freq
    class Thru < Base
      include Singleton

      def note_num(soundinfo, note)
        note.num
      end
    end
  end
end
