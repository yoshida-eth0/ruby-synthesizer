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

synth = PolySynth.new(
  oscillators: [
    Oscillator.new(
      source: OscillatorSource::Sawtooth.instance,
      sync: ModulationValue.new(0.0)
        .add(Modulation::Lfo.new(
          shape: Shape::PositiveRampUp,
          delay: 0.0,
          attack: 0.0,
          attack_curve: Modulation::Curve::Straight,
          phase: 0.0,
          rate: 0.2
        ), depth: 48),
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

bufs += 50.times.map {|_| synth.next}
synth.note_on(Note.new(60))
bufs += 200.times.map {|_| synth.next}
synth.note_off(Note.new(60))
bufs += 50.times.map {|_| synth.next}


track1 = AudioInput.buffer(bufs)

stereo_out = AudioOutput.device(soundinfo: soundinfo)

track1
  .send_to(stereo_out, gain: 0.25)


conductor = Conductor.new(
  input: [track1],
  output: [stereo_out]
)
conductor.connect
conductor.join
