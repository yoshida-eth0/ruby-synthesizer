require 'synthesizer/version'

# audio_stream extension
require 'audio_stream'
require 'audio_stream/audio_input_synth.rb'
require 'audio_stream/audio_input_metronome.rb'
require 'audio_stream/audio_input_step_editor'
require 'synthesizer/step_editor'
require 'audio_stream/decibel/dx7'

# generate wave
require 'synthesizer/shape'
require 'synthesizer/shape_pos'
require 'synthesizer/modulation_value'
require 'synthesizer/modulation'
require 'synthesizer/oscillator_source'

# parameter
require 'synthesizer/note'
require 'synthesizer/freq'

# synthesizer
require 'synthesizer/poly_synth'
require 'synthesizer/mono_synth'
require 'synthesizer/oscillator'
require 'synthesizer/filter'
require 'synthesizer/amplifier'
require 'synthesizer/note_perform'
require 'synthesizer/unison'
require 'synthesizer/processor'
require 'synthesizer/quality'
require 'synthesizer/utils'

# fm synthesizer
require 'synthesizer/fm_synth'
require 'synthesizer/operator'
require 'synthesizer/algorithm'

# drum machine
require 'synthesizer/drum_machine_designer'

module Synthesizer
end
