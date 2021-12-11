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

synth = PolySynth.new(
  oscillators: [
    Oscillator.new(
      source: OscillatorSource::SquareSawtooth.instance,
      uni_num: ModulationValue.new(4)
        .add(Modulation::Lfo.new(
        )),
      uni_detune: 0.1,
    ),
    #Oscillator.new(
    #  source: OscillatorSource::SquareSawtooth.instance,
    #  tune_cents: 0.1,
    #  uni_num: 4,
    #  uni_detune: 0.1,
    #),
    #Oscillator.new(
    #  source: OscillatorSource::SquareSawtooth.instance,
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
  soundinfo: soundinfo,
)
bufs = []

synth.note_on(Note.new(60))
synth.note_on(Note.new(62))
synth.note_on(Note.new(64))
bufs += 10.times.map {|_| synth.next}
synth.pitch_bend = 1
bufs += 10.times.map {|_| synth.next}
synth.pitch_bend = 2
bufs += 10.times.map {|_| synth.next}

synth.note_off(Note.new(60))
synth.note_off(Note.new(62))
synth.note_off(Note.new(64))
bufs += 50.times.map {|_| synth.next}


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
