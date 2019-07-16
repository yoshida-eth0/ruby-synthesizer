require 'synthesizer'
require 'audio_stream/core_ext'

include AudioStream

soundinfo = SoundInfo.new(
  channels: 2,
  samplerate: 44100,
  window_size: 1024,
  format: RubyAudio::FORMAT_WAV|RubyAudio::FORMAT_PCM_16
)

synth = Synthesizer::Mono.new(
  oscs: [
    Synthesizer::Osc.new(
      shape: Synthesizer::Shape::SquareSawtooth,
      uni_num: Synthesizer::Param.new(4)
        .add(Synthesizer::Modulation::Lfo.new(
        )),
      uni_detune: 0.1,
    ),
    #Synthesizer::Osc.new(
    #  shape: Synthesizer::Shape::SquareSawtooth,
    #  tune_cents: 0.1,
    #  uni_num: 4,
    #  uni_detune: 0.1,
    #),
    #Synthesizer::Osc.new(
    #  shape: Synthesizer::Shape::SquareSawtooth,
    #  tune_semis: -12,
    #  uni_num: 4,
    #  uni_detune: 0.1,
    #),
  ],
  amp: Synthesizer::Amp.new(
    volume: Synthesizer::Param.new(1.0)
      .add(Synthesizer::Modulation::Adsr.new(
        attack: 0.05,
        hold: 0.1,
        decay: 0.4,
        sustain: 0.8,
        release: 0.2
      ), depth: 1.0),
    ),
  glide: 0.2,
  quality: Synthesizer::Quality::LOW,
  soundinfo: soundinfo,
)
bufs = []

synth.note_on(Synthesizer::Note.new(60))
bufs += 50.times.map {|_| synth.next}
synth.note_on(Synthesizer::Note.new(62))
bufs += 50.times.map {|_| synth.next}
synth.note_on(Synthesizer::Note.new(64))
bufs += 50.times.map {|_| synth.next}
synth.note_on(Synthesizer::Note.new(62))
bufs += 50.times.map {|_| synth.next}

synth.note_off(Synthesizer::Note.new(62))
bufs += 50.times.map {|_| synth.next}
synth.note_off(Synthesizer::Note.new(64))
bufs += 50.times.map {|_| synth.next}
synth.note_off(Synthesizer::Note.new(60))
synth.note_on(Synthesizer::Note.new(65))
bufs += 50.times.map {|_| synth.next}
synth.note_off(Synthesizer::Note.new(65))
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
