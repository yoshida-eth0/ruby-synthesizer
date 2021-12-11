$LOAD_PATH << File.dirname(__FILE__) + "/../lib"
$LOAD_PATH << File.dirname(__FILE__) + "/../../ruby-audio_stream/lib"

require 'synthesizer'
require 'audio_stream'

include AudioStream
include AudioStream::Fx

samplerate_list = [44100, 48000]
available_samplerates = CoreAudio.default_output_device.available_sample_rate.flatten.uniq
samplerate = samplerate_list.find {|rate| available_samplerates.include?(rate)} || available_samplerates.max

soundinfo = SoundInfo.new(
  channels: 2,
  samplerate: samplerate,
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

gain = AGain.new(level: -15)


# Bus

#stereo_out = AudioOutput.file("out.wav", soundinfo)
stereo_out = AudioOutput.device(soundinfo: soundinfo)
bus1 = AudioBus.new


# Mixer

track1
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
