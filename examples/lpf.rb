require 'synthesizer'
require 'audio_stream/core_ext'

include AudioStream

soundinfo = SoundInfo.new(
  channels: 2,
  samplerate: 44100,
  window_size: 1024,
  format: RubyAudio::FORMAT_WAV|RubyAudio::FORMAT_PCM_16
)

synth = Synthesizer::Poly.new(
  oscillators: [
    Synthesizer::Oscillator.new(
      shape: Synthesizer::Shape::WhiteNoise
    ),
  ],
  filter: Synthesizer::Filter::Serial.new(
    Synthesizer::Filter::LowPassFilter.new(
      freq: Synthesizer::ModulationValue.new(440.0)
        .add(Synthesizer::Modulation::Adsr.new(
          attack: 3.0,
          hold: 0.0,
          decay: 0.0,
          sustain: 0.0,
          release: 1.0
        ), depth: 3000.0),
    ),
    Synthesizer::Filter::HighPassFilter.new(
      freq: Synthesizer::ModulationValue.new(400.0)
        .add(Synthesizer::Modulation::Adsr.new(
          attack: 3.0,
          hold: 0.0,
          decay: 0.0,
          sustain: 0.0,
          release: 1.0
        ), depth: 3000.0),
    ),
  ),
  amplifier: Synthesizer::Amplifier.new(
    volume: Synthesizer::ModulationValue.new(1.0)
      .add(Synthesizer::Modulation::Adsr.new(
        attack: 0.05,
        hold: 0.1,
        decay: 0.4,
        sustain: 0.8,
        release: 0.2
      ), depth: 1.0),
    ),
  quality: Synthesizer::Quality::LOW,
  soundinfo: soundinfo,
)
bufs = []

synth.note_on(Synthesizer::Note.new(60))
bufs += 100.times.map {|_| synth.next}

synth.note_off(Synthesizer::Note.new(60))
bufs += 50.times.map {|_| synth.next}


track1 = AudioInput.buffer(bufs)

stereo_out = AudioOutput.device(soundinfo: soundinfo)

track1
  .stream
  .send_to(stereo_out, gain: 0.25)


conductor = Conductor.new(
  input: [track1],
  output: [stereo_out]
)
conductor.connect
conductor.join
