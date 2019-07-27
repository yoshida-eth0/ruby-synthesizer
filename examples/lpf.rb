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
      shape: Shape::WhiteNoise
    ),
  ],
  filter: Filter::Serial.new(
    Filter::LowPassFilter.new(
      freq: ModulationValue.new(440.0)
        .add(Modulation::Adsr.new(
          attack: 3.0,
          hold: 0.0,
          decay: 0.0,
          sustain: 0.0,
          release: 1.0
        ), depth: 3000.0),
    ),
    Filter::HighPassFilter.new(
      freq: ModulationValue.new(400.0)
        .add(Modulation::Adsr.new(
          attack: 3.0,
          hold: 0.0,
          decay: 0.0,
          sustain: 0.0,
          release: 1.0
        ), depth: 3000.0),
    ),
  ),
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
  quality: Quality::LOW,
  soundinfo: soundinfo,
)
bufs = []

synth.note_on(Note.new(60))
bufs += 100.times.map {|_| synth.next}

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
