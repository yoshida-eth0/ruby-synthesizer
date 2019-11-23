require 'synthesizer'
require 'audio_stream'

include AudioStream
include Synthesizer

soundinfo = SoundInfo.new(
  channels: 2,
  samplerate: 44100,
  window_size: 1024,
  format: RubyAudio::FORMAT_WAV|RubyAudio::FORMAT_PCM_16
)

source = nil

synth = PolySynth.new(
  oscillators: [
    Oscillator.new(
      source: source = OscillatorSource::FormantVocoder.new(
        vowels: [:a],
      ),
      phase: 0.0,
    ),
  ],
  amplifier: Amplifier.new(
    volume: ModulationValue.new(1.0)
      .add(Modulation::Adsr.new(
        attack: 0.05,
        hold: 0.1,
        decay: 0.4,
        sustain: 0.8,
        release: 0.2
      ), depth: 1.0),
    ),
  soundinfo: soundinfo,
)
bufs = []
base = 36

source.vowels = [:a]
synth.note_on(Note.new(base))
bufs += 50.times.map {|_| synth.next}
synth.note_off(Note.new(base))
bufs += 20.times.map {|_| synth.next}

source.vowels = [:i]
synth.note_on(Note.new(base))
bufs += 50.times.map {|_| synth.next}
synth.note_off(Note.new(base))
bufs += 20.times.map {|_| synth.next}

source.vowels = [:u]
synth.note_on(Note.new(base))
bufs += 50.times.map {|_| synth.next}
synth.note_off(Note.new(base))
bufs += 20.times.map {|_| synth.next}

source.vowels = [:e]
synth.note_on(Note.new(base))
bufs += 50.times.map {|_| synth.next}
synth.note_off(Note.new(base))
bufs += 20.times.map {|_| synth.next}

source.vowels = [:o]
synth.note_on(Note.new(base))
bufs += 50.times.map {|_| synth.next}
synth.note_off(Note.new(base))

bufs += 50.times.map {|_| synth.next}


track1 = AudioInput.buffer(bufs)

stereo_out = AudioOutput.device(soundinfo: soundinfo)
#stereo_out = AudioOutput.file("formatvocoder_osc.wav", soundinfo: soundinfo)

track1
  .send_to(stereo_out, gain: 1.0)


conductor = Conductor.new(
  input: [track1],
  output: [stereo_out]
)
conductor.connect
conductor.join
