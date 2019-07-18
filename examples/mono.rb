require 'synthesizer'
require 'audio_stream/core_ext'

include AudioStream
include Synthesizer

soundinfo = SoundInfo.new(
  channels: 2,
  samplerate: 44100,
  window_size: 1024,
  format: RubyAudio::FORMAT_WAV|RubyAudio::FORMAT_PCM_16
)

synth = MonoSynth.new(
  oscillators: [
    Oscillator.new(
      shape: Shape::SquareSawtooth,
      uni_num: ModulationValue.new(4),
        #.add(Modulation::Lfo.new(
        #)),
      uni_detune: 0.1,
    ),
    #Oscillator.new(
    #  shape: Shape::SquareSawtooth,
    #  tune_cents: 0.1,
    #  uni_num: 4,
    #  uni_detune: 0.1,
    #),
    #Oscillator.new(
    #  shape: Shape::SquareSawtooth,
    #  tune_semis: -12,
    #  uni_num: 4,
    #  uni_detune: 0.1,
    #),
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
  glide: 0.2,
  quality: Quality::LOW,
  soundinfo: soundinfo,
)
bufs = []

synth.note_on(Note.new(60))
bufs += 50.times.map {|_| synth.next}
synth.note_on(Note.new(62))
bufs += 50.times.map {|_| synth.next}
synth.note_on(Note.new(64))
bufs += 50.times.map {|_| synth.next}
synth.note_on(Note.new(62))
bufs += 50.times.map {|_| synth.next}

synth.note_off(Note.new(62))
bufs += 50.times.map {|_| synth.next}
synth.note_off(Note.new(64))
bufs += 50.times.map {|_| synth.next}
synth.note_off(Note.new(60))
synth.note_on(Note.new(65))
bufs += 50.times.map {|_| synth.next}
synth.note_off(Note.new(65))
bufs += 50.times.map {|_| synth.next}


track1 = AudioInput.buffer(bufs)

stereo_out = AudioOutput.device(soundinfo: soundinfo)

track1
  .stream
  .send_to(stereo_out, gain: 0.3)


conductor = Conductor.new(
  input: [track1],
  output: [stereo_out]
)
conductor.connect
conductor.join
