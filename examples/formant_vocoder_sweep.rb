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
      source: OscillatorSource::FormantVocoder.new(
        vowels: [:a, :i, :u, :e, :o],
        #vowels: [:i, :e, :a, :o, :u],
        pronunciation: ModulationValue.new(0)
          .add(Modulation::Lfo.new(
            shape: Shape::ForeverRampUp,
            rate: 2.0,
          )),
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
synth.note_on(Note.new(base))
bufs += 100.times.map {|_| synth.next}
synth.note_off(Note.new(base))
bufs += 20.times.map {|_| synth.next}

synth.note_on(Note.new(base+4))
bufs += 100.times.map {|_| synth.next}
synth.note_off(Note.new(base+4))
bufs += 20.times.map {|_| synth.next}

synth.note_on(Note.new(base+7))
bufs += 100.times.map {|_| synth.next}
synth.note_off(Note.new(base+7))
bufs += 20.times.map {|_| synth.next}

bufs += 50.times.map {|_| synth.next}


track1 = AudioInput.buffer(bufs)

stereo_out = AudioOutput.device(soundinfo: soundinfo)
#stereo_out = AudioOutput.file("formant_vocoder_sweep.wav", soundinfo: soundinfo)

track1
  .send_to(stereo_out, gain: 1.0)


conductor = Conductor.new(
  input: [track1],
  output: [stereo_out]
)
conductor.connect
conductor.join
