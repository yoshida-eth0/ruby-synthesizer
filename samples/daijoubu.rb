$LOAD_PATH << File.dirname(__FILE__) + "/../lib"
$LOAD_PATH << File.dirname(__FILE__) + "/../../ruby-audio_stream/lib"

require 'synthesizer'
require 'audio_stream'

include AudioStream
include AudioStream::Fx
include Synthesizer

class Daijoubu
  def initialize
    @soundinfo = SoundInfo.new(
      channels: 2,
      samplerate: 44100,
      window_size: 1024,
      format: RubyAudio::FORMAT_WAV|RubyAudio::FORMAT_PCM_16,
      bpm: 130
    )

    @default_amp = Amplifier.new(
      volume: ModulationValue.new(1.0)
        .add(Modulation::Adsr.new(
          attack: Rate.sec(0.05),
          hold: Rate.sec(0.1),
          decay: Rate.sec(0.4),
          sustain: 0.8,
          release: Rate.sec(0.3)
        ), depth: 1.0),
    )

    @inputs = {
      up_noise: create_up_noise,
      intro_arpeggio: create_intro_arpeggio,
      vocal1: create_vocal1,
      vocal2: create_vocal2,
      lead1: create_lead1,
      lead_mono: create_lead_mono,
      lead_wide: create_lead_wide,
      chord: create_chord,
      bass: create_bass,
      drum: AudioInput.file(File.dirname(__FILE__)+"/daijoubu_drum.wav", soundinfo: @soundinfo),
    }

    #@output = AudioOutput.device(soundinfo: @soundinfo)
    @output = AudioOutput.file(File.dirname(__FILE__)+"/output_daijoubu.wav", soundinfo: @soundinfo)
  end

  def create_up_noise
    synth = PolySynth.new(
      oscillators: [
        Oscillator.new(
          source: OscillatorSource::WhiteNoise.instance
        ),
      ],
      filter: Filter::BandPassFilter.new(
        freq: ModulationValue.new(100.0)
          .add(Modulation::Adsr.new(
            attack: Rate::SYNC_2,
            attack_curve: Modulation::Curve::Straight,
            hold: Rate.sec(0.0),
            decay: Rate.sec(0.0),
            sustain: 0.0,
            release: Rate.sec(2.0)
          ), depth: 6000.0),
        bandwidth: 0.3,
      ),
      amplifier: Amplifier.new(
        volume: ModulationValue.new(1.0)
          .add(Modulation::Adsr.new(
            attack: Rate::SYNC_6,
            attack_curve: Modulation::Curve::Straight,
            hold: Rate.sec(0.1),
            decay: Rate.sec(0.0),
            sustain: 1.0,
            release: Rate.sec(0.2)
          ), depth: 1.0),
      ),
      soundinfo: @soundinfo,
    )

    se = StepEditor::StGt.new(bpm: @soundinfo.bpm) {|se|
      se.step(480*2)

      se.note(Note.new(64), st: 480, gt: 480*8)
      se.note(Note.new(62), st: 480, gt: 480*7)
      se.note(Note.new(60), st: 480*6, gt: 480*6)

      se.step(480*2)
      se.complete
    }

    AudioInputStepEditor.new(synth, se)
  end

  def create_intro_arpeggio
    synth = PolySynth.new(
      oscillators: [
        Oscillator.new(
          source: OscillatorSource::SawtoothSine.instance,
          uni_num: 4,
          uni_detune: 0.1,
        ),
      ],
      amplifier: @default_amp,
      soundinfo: @soundinfo,
    )

    se = StepEditor::StGt.new(bpm: @soundinfo.bpm) {|se|
      se.step(480*2)

      se.step(480*2)

      2.times {|i|
        se.note(Note.create(:B, 5),    gt: 120, vel: 0.1*(i+1))
        se.step(120)
        se.note(Note.create(:A, 5),    gt: 120, vel: 0.1*(i+1))
        se.step(120)
        se.note(Note.create(:"G#", 5), gt: 120, vel: 0.1*(i+1))
        se.step(120)
        se.note(Note.create(:E, 5),    gt: 120, vel: 0.1*(i+1))
        se.step(120)
      }

      3.times {|i|
        se.note(Note.create(:B, 5),    gt: 120, vel: 0.1*(i+3))
        se.note(Note.create(:B, 3),    gt: 120, vel: 0.1*(i+1))
        se.step(120)
        se.note(Note.create(:A, 5),    gt: 120, vel: 0.1*(i+3))
        se.note(Note.create(:A, 3),    gt: 120, vel: 0.1*(i+1))
        se.step(120)
        se.note(Note.create(:"G#", 5), gt: 120, vel: 0.1*(i+3))
        se.note(Note.create(:"G#", 3), gt: 120, vel: 0.1*(i+1))
        se.step(120)
        se.note(Note.create(:E, 5),    gt: 120, vel: 0.1*(i+3))
        se.note(Note.create(:E, 3),    gt: 120, vel: 0.1*(i+1))
        se.step(120)
      }

      se.note(Note.create(:B, 5),    gt: 120, vel: 0.6)
      se.note(Note.create(:E, 4),    gt: 120, vel: 0.4)
      se.step(120)
      se.note(Note.create(:A, 5),    gt: 120, vel: 0.6)
      se.note(Note.create(:"G#", 4), gt: 120, vel: 0.4)
      se.step(120)
      se.note(Note.create(:"G#", 5), gt: 120, vel: 0.6)
      se.note(Note.create(:E, 4),    gt: 120, vel: 0.4)
      se.step(120)
      se.note(Note.create(:E, 5),    gt: 120, vel: 0.6)
      se.note(Note.create(:B, 3),    gt: 120, vel: 0.4)
      se.step(120)

      se.step(480*2)
      se.complete
    }

    AudioInputStepEditor.new(synth, se)
  end

  def create_vocal1
    synth = MonoSynth.new(
      oscillators: [
        Oscillator.new(
          source: OscillatorSource::SquareSine.instance,
        ),
      ],
      amplifier: @default_amp,
      glide: Rate.sec(0.08),
      soundinfo: @soundinfo,
    )

    se = StepEditor::StGt.new(bpm: @soundinfo.bpm) {|se|
      se.step(480*2)

      se.step(480*8)
      se.note(Note.create(:"A#", 5), st: 60, gt: 120)
      se.note(Note.create(:B, 5), st: 420, gt: 420)
      se.note(Note.create(:B, 5), st: 240, gt: 240)
      se.note(Note.create(:"D#", 5), st: 120, gt: 120)
      se.note(Note.create(:E, 5), st: 1080, gt: 360)
      se.step(480*4)

      se.note(Note.create(:"A#", 5), st: 60, gt: 120)
      se.note(Note.create(:B, 5), st: 420, gt: 420)
      se.note(Note.create(:B, 5), st: 240, gt: 240)
      se.note(Note.create(:"D#", 5), st: 120, gt: 120)
      se.note(Note.create(:E, 5), st: 360, gt: 360)
      se.note(Note.create(:B, 4), st: 240, gt: 240)
      se.note(Note.create(:E, 5), st: 240, gt: 240)
      se.note(Note.create(:"C#", 6), st: 240, gt: 240)
      se.note(Note.create(:B, 5), st: 240, gt: 240)
      se.note(Note.create(:A, 5), st: 240, gt: 240)
      se.note(Note.create(:"G#", 5), st: 240, gt: 240)
      se.note(Note.create(:E, 5), st: 240, gt: 240)
      se.note(Note.create(:"F#", 5), st: 360, gt: 360)
      se.note(Note.create(:G, 5), st: 60, gt: 120)
      se.note(Note.create(:"G#", 5), st: 300, gt: 300)
      se.note(Note.create(:E, 5), st: 240, gt: 240)

      se.step(240)
      se.note(Note.create(:B, 4), st: 240, gt: 240)
      se.note(Note.create(:"D#", 5), st: 240, gt: 240)
      se.note(Note.create(:E, 5), st: 120, gt: 120)
      se.note(Note.create(:F, 5), st: 60, gt: 120)
      se.note(Note.create(:"F#", 5), st: 300, gt: 300)
      se.note(Note.create(:E, 5), st: 240, gt: 240)
      se.note(Note.create(:"F#", 5), st: 240, gt: 240)
      se.note(Note.create(:"G#", 5), st: 240, gt: 240)
      se.note(Note.create(:"F#", 5), st: 360, gt: 360)
      se.note(Note.create(:E, 5), st: 360, gt: 360)
      se.note(Note.create(:"F#", 5), st: 480, gt: 480)
      se.note(Note.create(:"G#", 5), st: 240, gt: 240)
      se.note(Note.create(:"F#", 5), st: 240, gt: 240)
      se.note(Note.create(:E, 5), st: 240, gt: 240)

      se.note(Note.create(:"A#", 5), st: 60, gt: 120)
      se.note(Note.create(:B, 5), st: 420, gt: 420)
      se.note(Note.create(:B, 5), st: 240, gt: 240)
      se.note(Note.create(:"D#", 5), st: 120, gt: 120)
      se.note(Note.create(:E, 5), st: 360, gt: 360)
      se.note(Note.create(:B, 4), st: 240, gt: 240)
      se.note(Note.create(:E, 5), st: 240, gt: 240)
      se.note(Note.create(:"C#", 6), st: 240, gt: 240)
      se.note(Note.create(:B, 5), st: 240, gt: 240)
      se.note(Note.create(:A, 5), st: 240, gt: 240)
      se.note(Note.create(:"G#", 5), st: 240, gt: 240)
      se.note(Note.create(:E, 5), st: 240, gt: 240)
      se.note(Note.create(:"F#", 5), st: 360, gt: 360)
      se.note(Note.create(:G, 5), st: 60, gt: 120)
      se.note(Note.create(:"G#", 5), st: 300, gt: 300)
      se.note(Note.create(:E, 5), st: 240, gt: 240)

      se.step(240)
      se.note(Note.create(:E, 5), st: 240, gt: 240)
      se.note(Note.create(:"D#", 5), st: 240, gt: 240)
      se.note(Note.create(:E, 5), st: 480, gt: 240)
      se.note(Note.create(:E, 5), st: 240, gt: 240)
      se.note(Note.create(:B, 5), st: 240, gt: 240)
      se.note(Note.create(:E, 5), st: 480, gt: 240)
      se.note(Note.create(:B, 4), st: 240, gt: 240)
      se.note(Note.create(:E, 5), st: 240, gt: 240)
      se.note(Note.create(:B, 5), st: 240, gt: 240)
      se.note(Note.create(:A, 5), st: 240, gt: 240)
      se.note(Note.create(:"G#", 5), st: 240, gt: 240)
      se.note(Note.create(:"F#", 5), st: 240, gt: 240)
      se.note(Note.create(:"G#", 5), st: 240, gt: 240)
      se.note(Note.create(:"F#", 5), st: 240, gt: 240)
      se.note(Note.create(:"G#", 5), st: 120, gt: 120)
      se.note(Note.create(:E, 5), st: 1080, gt: 1080)

      se.step(480*2)
      se.complete
    }

    AudioInputStepEditor.new(synth, se)
  end

  def create_vocal2
    synth = MonoSynth.new(
      oscillators: [
        Oscillator.new(
          source: OscillatorSource::SquareSine.instance,
          uni_num: 4,
          uni_detune: 0.1,
        ),
      ],
      amplifier: @default_amp,
      glide: Rate.sec(0.08),
      soundinfo: @soundinfo,
    )

    se = StepEditor::StGt.new(bpm: @soundinfo.bpm) {|se|
      se.step(480*2)

      se.step(480*8)
      se.step(480*2)
      se.note(Note.create(:"A#", 5), st: 60, gt: 120)
      se.note(Note.create(:B, 5), st: 420, gt: 420)
      se.note(Note.create(:B, 5), st: 240, gt: 240)
      se.note(Note.create(:"D#", 5), st: 120, gt: 120)
      se.note(Note.create(:E, 5), st: 1080, gt: 360)

      se.step(480*2)
      se.complete
    }

    AudioInputStepEditor.new(synth, se)
  end

  def create_lead1
    synth = PolySynth.new(
      oscillators: [
        Oscillator.new(
          source: OscillatorSource::SawtoothTriangle.instance,
        ),
      ],
      amplifier: @default_amp,
      soundinfo: @soundinfo,
    )

    se = StepEditor::StGt.new(bpm: @soundinfo.bpm) {|se|
      se.step(480*2)

      se.step(480*8)
      se.step(480*3)
      se.note(Note.create(:"C#", 5), st: 240, gt: 120)
      se.note(Note.create(:"D#", 5), st: 240, gt: 120)
      se.note(Note.create(:E, 5), st: 380, gt: 380)
      se.note(Note.create(:"F#", 5), st: 380, gt: 380)
      se.note(Note.create(:"G#", 5), st: 480, gt: 480)
      se.note(Note.create(:E, 5), st: 240, gt: 240)
      se.note(Note.create(:B, 5), st: 480, gt: 480)

      se.step(480*2)
      se.complete
    }

    AudioInputStepEditor.new(synth, se)
  end

  def create_lead_mono
    synth = MonoSynth.new(
      oscillators: [
        Oscillator.new(
          source: OscillatorSource::SawtoothTriangle.instance,
        ),
      ],
      amplifier: @default_amp,
      glide: Rate.sec(0.15),
      soundinfo: @soundinfo,
    )

    se = StepEditor::StGt.new(bpm: @soundinfo.bpm) {|se|
      se.step(480*2)

      se.step(480*16)

      se.note(Note.create(:B, 5), st: 480, gt: 481)
      se.note(Note.create(:E, 5), st: 480, gt: 481)
      se.note(Note.create(:"F#", 5), st: 480, gt: 481)
      se.note(Note.create(:A, 5), st: 480, gt: 481)
      se.note(Note.create(:"G#", 5), st: 480, gt: 481)
      se.note(Note.create(:E, 5), st: 480, gt: 481)
      se.note(Note.create(:"F#", 5), st: 480, gt: 481)
      se.note(Note.create(:E, 5), st: 480, gt: 481)

      se.note(Note.create(:B, 5), st: 480, gt: 481)
      se.note(Note.create(:E, 5), st: 480, gt: 481)
      se.note(Note.create(:"F#", 5), st: 480, gt: 481)
      se.note(Note.create(:A, 5), st: 480, gt: 481)
      se.note(Note.create(:"G#", 5), st: 480, gt: 481)
      se.note(Note.create(:A, 5), st: 480, gt: 481)
      se.note(Note.create(:B, 5), st: 480, gt: 481)
      se.note(Note.create(:E, 6), st: 480, gt: 481)

      se.note(Note.create(:B, 5), st: 480, gt: 481)
      se.note(Note.create(:E, 5), st: 480, gt: 481)
      se.note(Note.create(:"F#", 5), st: 480, gt: 481)
      se.note(Note.create(:A, 5), st: 480, gt: 481)
      se.note(Note.create(:"G#", 5), st: 480, gt: 481)
      se.note(Note.create(:E, 5), st: 480, gt: 481)
      se.note(Note.create(:"F#", 5), st: 480, gt: 481)
      se.note(Note.create(:E, 5), st: 480, gt: 481)

      se.note(Note.create(:"C#", 6), st: 960, gt: 961)
      se.note(Note.create(:"D#", 6), st: 960, gt: 961)
      se.note(Note.create(:E, 6), st: 960, gt: 961)
      se.note(Note.create(:B, 6), st: 960, gt: 960)

      se.step(480)
      se.note(Note.create(:B, 5), st: 480, gt: 481)
      se.note(Note.create(:E, 6), st: 480, gt: 481)
      se.note(Note.create(:"G#", 6), st: 480, gt: 481)
      se.note(Note.create(:A, 6), st: 960, gt: 960)

      se.step(480*2)
      se.complete
    }

    AudioInputStepEditor.new(synth, se)
  end

  def create_lead_wide
    synth = PolySynth.new(
      oscillators: [
        Oscillator.new(
          source: OscillatorSource::Sawtooth.instance,
          pan: -0.5,
          uni_num: 8,
          uni_detune: 0.07,
        ),
        Oscillator.new(
          source: OscillatorSource::Square.instance,
          pan: 0.5,
          uni_num: 8,
          uni_detune: 0.07,
        ),
      ],
      filter: Filter::Serial.new(
        Filter::HighShelfFilter.new(freq: 1500, gain: 2.0)
      ),
      amplifier: @default_amp,
      soundinfo: @soundinfo,
    )

    se = StepEditor::StGt.new(bpm: @soundinfo.bpm) {|se|
      se.step(480*2)

      se.step(480*16)

      2.times {|_|
        se.step(480*4)
        se.note(Note.create(:E, 5), st: 120, gt: 60)
        se.note(Note.create(:E, 5), st: 120, gt: 60)
        se.note(Note.create(:E, 5), st: 120, gt: 60)
        se.note(Note.create(:E, 5), st: 120, gt: 60)
        se.note(Note.create(:E, 5), st: 240, gt: 180)
        se.note(Note.create(:B, 4), st: 120, gt: 60)
        se.note(Note.create(:B, 4), st: 120, gt: 60)
        se.note(Note.create(:B, 4), st: 120, gt: 60)
        se.note(Note.create(:B, 4), st: 120, gt: 60)
        se.note(Note.create(:B, 4), st: 240, gt: 180)
        se.note(Note.create(:B, 4), st: 240, gt: 180)
        se.note(Note.create(:B, 4), st: 120, gt: 60)
        se.note(Note.create(:B, 4), st: 120, gt: 60)

        se.step(480*4)
        se.note(Note.create(:E, 5), st: 240, gt: 120)
        se.note(Note.create(:"D#", 5), st: 240, gt: 120)
        se.note(Note.create(:"C#", 5), st: 240, gt: 120)
        se.note(Note.create(:B, 4), st: 240, gt: 120)
        se.note(Note.create(:E, 5), st: 240, gt: 120)
        se.note(Note.create(:"D#", 5), st: 240, gt: 120)
        se.note(Note.create(:"C#", 5), st: 240, gt: 120)
        se.note(Note.create(:B, 4), st: 240, gt: 120)
      }

      se.step(480*4)
      se.note(Note.create(:A, 5), st: 360, gt: 120)
      se.note(Note.create(:A, 5), st: 240, gt: 120)
      se.note(Note.create(:A, 5), st: 240, gt: 120)
      se.note(Note.create(:"G#", 5), st: 120, gt: 120)

      se.step(480*2)
      se.complete
    }

    AudioInputStepEditor.new(synth, se)
  end

  def create_chord
    synth = PolySynth.new(
      oscillators: [
        Oscillator.new(
          source: OscillatorSource::Square.instance,
          pan: -0.5,
          uni_num: 4,
          uni_detune: 0.1,
        ),
        Oscillator.new(
          source: OscillatorSource::Sawtooth.instance,
          pan: 0.5,
          uni_num: 4,
          uni_detune: 0.1,
        ),
      ],
      filter: Filter::Serial.new(
        Filter::HighShelfFilter.new(freq: 2000, gain: 2.0)
      ),
      amplifier:  Amplifier.new(
        volume: ModulationValue.new(1.0)
          .add(Modulation::Adsr.new(
            attack: Rate.sec(0.05),
            hold: Rate.sec(0.0),
            decay: Rate.sec(0.1),
            sustain: 0.8,
            release: Rate.sec(0.05)
          ), depth: 1.0),
      ),
      soundinfo: @soundinfo,
    )

    se = StepEditor::StGt.new(bpm: @soundinfo.bpm) {|se|
      se.step(480*2)
      se.step(480*12)

      se.note(Note.create(:E, 3), gt: 240)
      se.note(Note.create(:"G#", 3), gt: 240)
      se.note(Note.create(:B, 3), st: 360, gt: 240)
      se.note(Note.create(:E, 3), gt: 240)
      se.note(Note.create(:"G#", 3), gt: 240)
      se.note(Note.create(:B, 3), st: 360, gt: 240)
      se.note(Note.create(:E, 3), gt: 240)
      se.note(Note.create(:"G#", 3), gt: 240)
      se.note(Note.create(:B, 3), st: 480, gt: 240)
      se.note(Note.create(:E, 3), gt: 240)
      se.note(Note.create(:"G#", 3), gt: 240)
      se.note(Note.create(:B, 3), st: 240, gt: 240)
      se.note(Note.create(:E, 3), gt: 240)
      se.note(Note.create(:"G#", 3), gt: 240)
      se.note(Note.create(:B, 3), st: 480, gt: 240)

      2.times {|_|
        se.note(Note.create(:A, 4), gt: 360)
        se.note(Note.create(:"C#", 5), gt: 360)
        se.note(Note.create(:E, 5), st: 480, gt: 360)
        se.note(Note.create(:A, 4), gt: 240)
        se.note(Note.create(:"C#", 5), gt: 240)
        se.note(Note.create(:E, 5), st: 600, gt: 240)
        se.note(Note.create(:B, 4), gt: 240)
        se.note(Note.create(:"D#", 5), gt: 240)
        se.note(Note.create(:"F#", 5), st: 360, gt: 240)
        se.note(Note.create(:B, 4), gt: 120)
        se.note(Note.create(:"D#", 5), gt: 120)
        se.note(Note.create(:"F#", 5), st: 240, gt: 120)
        se.note(Note.create(:B, 4), gt: 60)
        se.note(Note.create(:"D#", 5), gt: 60)
        se.note(Note.create(:"F#", 5), st: 120, gt: 60)
        se.note(Note.create(:B, 4), gt: 60)
        se.note(Note.create(:"D#", 5), gt: 60)
        se.note(Note.create(:"F#", 5), st: 120, gt: 60)

        se.step(240)
        se.note(Note.create(:E, 5), gt: 240)
        se.note(Note.create(:"G#", 5), gt: 240)
        se.note(Note.create(:B, 5), st: 480, gt: 240)
        se.note(Note.create(:E, 5), gt: 240)
        se.note(Note.create(:"G#", 5), gt: 240)
        se.note(Note.create(:B, 5), st: 360, gt: 240)
        se.note(Note.create(:"C#", 5), gt: 240)
        se.note(Note.create(:E, 5), gt: 240)
        se.note(Note.create(:"G#", 5), st: 360, gt: 240)
        se.note(Note.create(:"C#", 5), gt: 120)
        se.note(Note.create(:E, 5), gt: 120)
        se.note(Note.create(:"G#", 5), st: 240, gt: 120)
        se.note(Note.create(:"C#", 5), gt: 60)
        se.note(Note.create(:E, 5), gt: 60)
        se.note(Note.create(:"G#", 5), st: 120, gt: 60)
        se.note(Note.create(:"C#", 5), gt: 60)
        se.note(Note.create(:E, 5), gt: 60)
        se.note(Note.create(:"G#", 5), st: 120, gt: 60)
      }

      se.note(Note.create(:A, 4), gt: 360)
      se.note(Note.create(:"C#", 5), gt: 360)
      se.note(Note.create(:E, 5), st: 480, gt: 360)
      se.note(Note.create(:A, 4), gt: 240)
      se.note(Note.create(:"C#", 5), gt: 240)
      se.note(Note.create(:E, 5), st: 600, gt: 240)
      se.note(Note.create(:B, 4), gt: 240)
      se.note(Note.create(:"D#", 5), gt: 240)
      se.note(Note.create(:"F#", 5), st: 360, gt: 240)
      se.note(Note.create(:B, 4), gt: 120)
      se.note(Note.create(:"D#", 5), gt: 120)
      se.note(Note.create(:"F#", 5), st: 240, gt: 120)
      se.note(Note.create(:B, 4), gt: 60)
      se.note(Note.create(:"D#", 5), gt: 60)
      se.note(Note.create(:"F#", 5), st: 120, gt: 60)
      se.note(Note.create(:B, 4), gt: 60)
      se.note(Note.create(:"D#", 5), gt: 60)
      se.note(Note.create(:"F#", 5), st: 120, gt: 60)

      se.note(Note.create(:B, 4), gt: 240)
      se.note(Note.create(:E, 5), gt: 240)
      se.note(Note.create(:"G#", 5), st: 480, gt: 240)
      se.note(Note.create(:B, 4), gt: 240)
      se.note(Note.create(:E, 5), gt: 240)
      se.note(Note.create(:"G#", 5), st: 480, gt: 240)
      se.note(Note.create(:"C#", 5), gt: 240)
      se.note(Note.create(:E, 5), gt: 240)
      se.note(Note.create(:"G#", 5), st: 480, gt: 240)
      se.note(Note.create(:"C#", 5), gt: 240)
      se.note(Note.create(:E, 5), gt: 240)
      se.note(Note.create(:"G#", 5), st: 480, gt: 240)

      se.note(Note.create(:"F#", 4), gt: 360)
      se.note(Note.create(:A, 4), gt: 360)
      se.note(Note.create(:"C#", 5), st: 480, gt: 360)
      se.note(Note.create(:"F#", 4), gt: 240)
      se.note(Note.create(:A, 4), gt: 240)
      se.note(Note.create(:"C#", 5), st: 600, gt: 240)
      se.note(Note.create(:"G#", 4), gt: 240)
      se.note(Note.create(:B, 4), gt: 240)
      se.note(Note.create(:"D#", 5), st: 360, gt: 240)
      se.note(Note.create(:"G#", 4), gt: 120)
      se.note(Note.create(:B, 4), gt: 120)
      se.note(Note.create(:"D#", 5), st: 240, gt: 120)
      se.note(Note.create(:"G#", 4), gt: 60)
      se.note(Note.create(:B, 4), gt: 60)
      se.note(Note.create(:"D#", 5), st: 120, gt: 60)
      se.note(Note.create(:"G#", 4), gt: 60)
      se.note(Note.create(:B, 4), gt: 60)
      se.note(Note.create(:"D#", 5), st: 120, gt: 60)

      se.note(Note.create(:A, 4), gt: 240)
      se.note(Note.create(:"C#", 5), gt: 240)
      se.note(Note.create(:E, 5), st: 480, gt: 240)
      se.note(Note.create(:A, 4), gt: 240)
      se.note(Note.create(:"C#", 5), gt: 240)
      se.note(Note.create(:E, 5), st: 480, gt: 240)
      se.note(Note.create(:B, 4), gt: 240)
      se.note(Note.create(:"D#", 5), gt: 240)
      se.note(Note.create(:"F#", 5), st: 480, gt: 240)
      se.note(Note.create(:B, 4), gt: 240)
      se.note(Note.create(:"D#", 5), gt: 240)
      se.note(Note.create(:"F#", 5), st: 480, gt: 240)

      se.note(Note.create(:E, 5), gt: 360)
      se.note(Note.create(:"G#", 5), gt: 360)
      se.note(Note.create(:B, 5), st: 480, gt: 360)
      se.note(Note.create(:E, 5), gt: 480)
      se.note(Note.create(:"G#", 5), gt: 480)
      se.note(Note.create(:B, 5), st: 600, gt: 480)
      se.note(Note.create(:E, 5), gt: 240)
      se.note(Note.create(:"G#", 5), gt: 240)
      se.note(Note.create(:B, 5), st: 360, gt: 240)
      se.note(Note.create(:E, 5), gt: 120)
      se.note(Note.create(:"G#", 5), gt: 120)
      se.note(Note.create(:B, 5), st: 240, gt: 120)
      se.note(Note.create(:E, 5), gt: 60)
      se.note(Note.create(:"G#", 5), gt: 60)
      se.note(Note.create(:B, 5), st: 120, gt: 60)
      se.note(Note.create(:E, 5), gt: 60)
      se.note(Note.create(:"G#", 5), gt: 60)
      se.note(Note.create(:B, 5), st: 120, gt: 60)

      se.note(Note.create(:E, 5), gt: 240)
      se.note(Note.create(:"G#", 5), gt: 240)
      se.note(Note.create(:B, 5), st: 360, gt: 240)
      se.note(Note.create(:E, 5), gt: 120)
      se.note(Note.create(:"G#", 5), gt: 120)
      se.note(Note.create(:B, 5), st: 240, gt: 120)
      se.note(Note.create(:E, 5), gt: 120)
      se.note(Note.create(:"G#", 5), gt: 120)
      se.note(Note.create(:B, 5), st: 240, gt: 120)
      se.note(Note.create(:E, 5), gt: 360)
      se.note(Note.create(:"G#", 5), gt: 360)
      se.note(Note.create(:B, 5), st: 480, gt: 360)

      se.step(480*2)
      se.complete
    }

    AudioInputStepEditor.new(synth, se)
  end

  def create_bass
    synth = PolySynth.new(
      oscillators: [
        Oscillator.new(
          #source: OscillatorSource::Sawtooth.instance,
          source: OscillatorSource::SquareTriangle.instance,
          uni_num: 1,
          uni_detune: 0.1,
        ),
      ],
      filter: Filter::Serial.new(
        Filter::LowPassFilter.new(freq: 300.0)
      ),
      amplifier: @default_amp,
      soundinfo: @soundinfo,
    )

    se = StepEditor::StGt.new(bpm: @soundinfo.bpm) {|se|
      se.step(480*2)

      se.step(480*8)

      se.note(Note.create(:A, 1), st: 480, gt: 480)
      se.note(Note.create(:A, 1), st: 480, gt: 480)
      se.note(Note.create(:B, 1), st: 480, gt: 480)
      se.note(Note.create(:B, 1), st: 480, gt: 480)
      se.note(Note.create(:E, 2), st: 360, gt: 240)
      se.note(Note.create(:E, 2), st: 360, gt: 240)
      se.note(Note.create(:E, 2), st: 480, gt: 360)
      se.note(Note.create(:E, 2), st: 240, gt: 240)
      se.note(Note.create(:E, 2), st: 480, gt: 480)

      2.times {|_|
        se.note(Note.create(:A, 1), st: 240, gt: 240)
        se.note(Note.create(:A, 2), st: 240, gt: 240)
        se.note(Note.create(:A, 1), st: 240, gt: 240)
        se.note(Note.create(:A, 2), st: 240, gt: 240)
        se.note(Note.create(:B, 1), st: 240, gt: 240)
        se.note(Note.create(:B, 2), st: 240, gt: 240)
        se.note(Note.create(:B, 1), st: 240, gt: 240)
        se.note(Note.create(:B, 2), st: 240, gt: 240)
        se.note(Note.create(:E, 1), st: 240, gt: 240)
        se.note(Note.create(:E, 2), st: 240, gt: 240)
        se.note(Note.create(:E, 1), st: 240, gt: 240)
        se.note(Note.create(:E, 2), st: 240, gt: 240)
        se.note(Note.create(:"C#", 1), st: 240, gt: 240)
        se.note(Note.create(:"C#", 2), st: 240, gt: 240)
        se.note(Note.create(:"C#", 3), st: 240, gt: 240)
        se.note(Note.create(:"C#", 2), st: 240, gt: 240)
      }

      se.note(Note.create(:A, 1), st: 240, gt: 240)
      se.note(Note.create(:A, 2), st: 240, gt: 240)
      se.note(Note.create(:A, 1), st: 240, gt: 240)
      se.note(Note.create(:A, 2), st: 240, gt: 240)
      se.note(Note.create(:B, 1), st: 240, gt: 240)
      se.note(Note.create(:B, 2), st: 240, gt: 240)
      se.note(Note.create(:B, 1), st: 240, gt: 240)
      se.note(Note.create(:B, 2), st: 240, gt: 240)
      se.note(Note.create(:C, 2), st: 240, gt: 240)
      se.note(Note.create(:C, 3), st: 240, gt: 240)
      se.note(Note.create(:C, 2), st: 240, gt: 240)
      se.note(Note.create(:C, 3), st: 240, gt: 240)
      se.note(Note.create(:"C#", 2), st: 240, gt: 240)
      se.note(Note.create(:"C#", 3), st: 240, gt: 240)
      se.note(Note.create(:"C#", 4), st: 240, gt: 240)
      se.note(Note.create(:"G#", 3), st: 240, gt: 240)

      se.note(Note.create(:"F#", 1), st: 240, gt: 240)
      se.note(Note.create(:"F#", 2), st: 240, gt: 240)
      se.note(Note.create(:"F#", 1), st: 240, gt: 240)
      se.note(Note.create(:"F#", 2), st: 240, gt: 240)
      se.note(Note.create(:"G#", 1), st: 240, gt: 240)
      se.note(Note.create(:"G#", 2), st: 240, gt: 240)
      se.note(Note.create(:"G#", 1), st: 240, gt: 240)
      se.note(Note.create(:"G#", 2), st: 240, gt: 240)
      se.note(Note.create(:A, 1), st: 240, gt: 240)
      se.note(Note.create(:A, 2), st: 240, gt: 240)
      se.note(Note.create(:A, 1), st: 240, gt: 240)
      se.note(Note.create(:A, 2), st: 240, gt: 240)
      se.note(Note.create(:B, 1), st: 240, gt: 240)
      se.note(Note.create(:B, 2), st: 120, gt: 120)
      se.note(Note.create(:"F#", 3), st: 120, gt: 120)
      se.note(Note.create(:B, 3), st: 240, gt: 240)
      se.note(Note.create(:B, 2), st: 240, gt: 240)

      se.note(Note.create(:E, 1), st: 240, gt: 240)
      se.note(Note.create(:E, 2), st: 240, gt: 240)
      se.note(Note.create(:E, 1), st: 240, gt: 240)
      se.note(Note.create(:E, 2), st: 240, gt: 240)
      se.note(Note.create(:E, 1), st: 240, gt: 240)
      se.note(Note.create(:E, 2), st: 240, gt: 240)
      se.note(Note.create(:E, 1), st: 240, gt: 240)
      se.note(Note.create(:E, 2), st: 240, gt: 240)
      se.note(Note.create(:E, 2), st: 960, gt: 960)
      se.note(Note.create(:E, 3), st: 240, gt: 240)

      se.step(480*4)

      se.complete
    }

    AudioInputStepEditor.new(synth, se)
  end

  def mixer
    bus1 = AudioBus.new

    @inputs[:up_noise]
      .fx(Compressor.new(threshold: 0.5, ratio: 0.6))
      .send_to(bus1, gain: -16.5)

    @inputs[:intro_arpeggio]
      .fx(Compressor.new(threshold: 0.5, ratio: 0.6))
      .send_to(bus1, gain: -12)

    @inputs[:vocal1]
      .send_to(bus1, gain: -14)

    @inputs[:vocal2]
      .send_to(bus1, gain: -12)

    @inputs[:lead1]
      .send_to(bus1, gain: -14)

    @inputs[:lead_mono]
      .send_to(bus1, gain: -17, pan: -0.5)

    @inputs[:lead_wide]
      .fx(Delay.new(@soundinfo, time: Rate.sec(0.25*1.5), level: -6, feedback: -100))
      .send_to(bus1, gain: -13, pan: 0.4)

    @inputs[:chord]
      .fx(Delay.new(@soundinfo, time: Rate.sec(0.3), level: -10, feedback: -10))
      .send_to(bus1, gain: -17, pan: 0.2)


    @inputs[:bass]
      .send_to(bus1, gain: -14)


    #impulse = AudioInput.file(File.dirname(__FILE__)+"/../../ruby-audio_stream/examples/IMreverbs/Small Drum Room.wav", soundinfo: @soundinfo).connect.to_a
    #impulse = AudioInput.file(File.dirname(__FILE__)+"/../../ruby-audio_stream/examples/IMreverbs/Direct Cabinet N2.wav", soundinfo: @soundinfo).connect.to_a
    #impulse = AudioInput.file(File.dirname(__FILE__)+"/../../ruby-audio_stream/examples/IMreverbs/Masonic Lodge.wav", soundinfo: @soundinfo).connect.to_a

    bus1
      .fx(Compressor.new(threshold: 0.5, ratio: 0.8))
      .send_to(@output, gain: -8)

      #.fx(ConvolutionReverb.new(impulse, dry: 0.9, wet: 0.5))

    @inputs[:drum]
      .send_to(@output, gain: 0)


    conductor = Conductor.new(
      input: @inputs.values,
      output: @output
    )
    conductor.connect
    conductor.join
  end
end

Daijoubu.new.mixer
