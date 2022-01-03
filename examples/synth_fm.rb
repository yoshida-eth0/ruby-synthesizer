$LOAD_PATH << File.dirname(__FILE__) + "/../lib"
$LOAD_PATH << File.dirname(__FILE__) + "/../../ruby-audio_stream/lib"

require 'synthesizer'
require 'audio_stream'

include AudioStream
include AudioStream::Fx
include Synthesizer

samplerate_list = [44100, 48000]
available_samplerates = CoreAudio.default_output_device.available_sample_rate.flatten.uniq
samplerate = samplerate_list.find {|rate| available_samplerates.include?(rate)} || available_samplerates.max

soundinfo = SoundInfo.new(
  channels: 2,
  samplerate: samplerate,
  window_size: 1024,
  format: RubyAudio::FORMAT_WAV|RubyAudio::FORMAT_PCM_16
)

carrier1 = Operator.new(
  source: OscillatorSource::Sine.instance,
  level: 1.0,
  fixed_freq: nil,
  ratio_freq: 1.0,
  envelope: Modulation::Dx7Envelope.new(
    r1: 99, r2: 99, r3: 40, r4: 40,
    l1: 99, l2: 99, l3: 0,  l4: 0
  ),
  pmd: 0.0,
  amd: 0.2,
)

modulator1 = Operator.new(
  source: OscillatorSource::Sine.instance,
  level: 0.7,
  fixed_freq: nil,
  ratio_freq: 8.0,
  envelope: Modulation::Dx7Envelope.new(
    r1: 99, r2: 99, r3: 40, r4: 40,
    l1: 99, l2: 99, l3: 0,  l4: 0
  ),
  pmd: 0.0,
  amd: 0.0,
)

synth = FmSynth.new(
  operators: {
    carrier1: carrier1,
    modulator1: modulator1,
  },
  algorithm: Algorithm.new
    .add(:modulator1, :carrier1),
  lfo: Modulation::Lfo.new(
    shape: Shape::Sine,
    delay: Rate.sec(0.0),
    attack: Rate.sec(0.0),
    attack_curve: Modulation::Curve::EaseIn,
    phase: 0.0,
    rate: Rate::sec(0.2)
  ),
  pitch_envelope: Modulation::Dx7PitchEnvelope::KEEP,
  quality: Quality::HIGH,
  soundinfo: soundinfo
).build

bufs = []

synth.note_on(Note.new(60))
bufs += 20.times.map {|_| synth.next}
synth.note_on(Note.new(64))
bufs += 20.times.map {|_| synth.next}
synth.note_on(Note.new(67))
bufs += 20.times.map {|_| synth.next}
synth.note_on(Note.new(72))
bufs += 100.times.map {|_| synth.next}

synth.note_off(Note.new(60))
synth.note_off(Note.new(64))
synth.note_off(Note.new(67))
synth.note_off(Note.new(72))
bufs += 20.times.map {|_| synth.next}


track1 = AudioInput.buffer(bufs)

stereo_out = AudioOutput.device(soundinfo: soundinfo)

track1
  .send_to(stereo_out, gain: -15)


conductor = Conductor.new(
  input: [track1],
  output: [stereo_out]
)
conductor.connect
conductor.join
