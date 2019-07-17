require 'synthesizer'
require 'audio_stream/core_ext'

include AudioStream
include AudioStream::Fx


soundinfo = SoundInfo.new(
  channels: 2,
  samplerate: 44100,
  window_size: 1024,
  format: RubyAudio::FORMAT_WAV|RubyAudio::FORMAT_PCM_16
)


# Track

track1 = AudioInputMetronome.new(
  bpm: 120.0,
  repeat: 1000,
  soundinfo: soundinfo
)


# Audio FX

gain = AGain.new(level: 0.9)


# Bus

#stereo_out = AudioOutput.file("out.wav", soundinfo)
stereo_out = AudioOutput.device(soundinfo: soundinfo)
bus1 = AudioBus.new


# Mixer

track1
  .stream
  .fx(gain)
  .send_to(bus1)

bus1
  .send_to(stereo_out)


# start

conductor = Conductor.new(
  input: track1,
  output: stereo_out
)
conductor.connect
conductor.join
