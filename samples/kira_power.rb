$LOAD_PATH << File.dirname(__FILE__) + "/../lib"
$LOAD_PATH << File.dirname(__FILE__) + "/../../ruby-audio_stream/lib"

require 'synthesizer'
require 'audio_stream'

include AudioStream
include AudioStream::Fx
include Synthesizer


class KiraPower
  def initialize
    @soundinfo = SoundInfo.new(
      channels: 2,
      samplerate: 44100,
      window_size: 1024,
      format: RubyAudio::FORMAT_WAV|RubyAudio::FORMAT_PCM_16,
      bpm: 139.0
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

    @vocal_vibrato = Modulation::Lfo.new(
      shape: Shape::Sine,
      delay: Rate.sec(0.0),
      attack: Rate::SYNC_1_8D,
      attack_curve: Modulation::Curve::EaseIn,
      phase: 0.0,
      rate: Rate::SYNC_1_8
    )


    @inputs = {
      vocal1: create_vocal1,
      vocal2: create_vocal2,
      chorus: create_chorus,
      chord: create_chord,
      slow_chord: create_slow_chord,
      arpeggio1: create_arpeggio1,
      arpeggio2: create_arpeggio2,
      bass: create_bass,
      dub1: create_dub1,
      dub2: create_dub2,
      white_noise: create_white_noise,
      drum: AudioInput.file(File.dirname(__FILE__)+"/kira_power_drum.wav", soundinfo: @soundinfo)
    }

    #@output = AudioOutput.device(soundinfo: @soundinfo)
    @output = AudioOutput.file(File.dirname(__FILE__)+"/output_kira_power.wav", soundinfo: @soundinfo)
  end

  def create_vocal1
    synth = MonoSynth.new(
      oscillators: [
        Oscillator.new(
          source: OscillatorSource::TriangleSquare.instance,
          tune_cents: ModulationValue.new(0.0)
            .add(@vocal_vibrato, depth: 30.0)
        ),
      ],
      filter: Filter::Serial.new(
        Filter::BandPassFilter.new(freq: 2600, bandwidth: 2.0)
      ),
      amplifier: @default_amp,
      soundinfo: @soundinfo,
    )

    se = StepEditor::StGt.new(bpm: @soundinfo.bpm) {|se|
      se.step(480*4)

      se.step(480*2)
      se.step(240)
      se.note(Note.create(:"D#", 5), gt: 1)
      se.note(Note.create(:E, 5), st: 240, gt: 240)
      se.note(Note.create(:E, 5), st: 240, gt: 240)
      se.note(Note.create(:E, 5), st: 240, gt: 240)
      se.note(Note.create(:"D#", 5), gt: 1)
      se.note(Note.create(:E, 5), st: 240, gt: 240)
      se.note(Note.create(:"D#", 5), st: 120, gt: 120)
      se.note(Note.create(:E, 5), st: 240, gt: 240)
      se.note(Note.create(:"F#", 5), st: 240, gt: 240)
      se.note(Note.create(:"F#", 5), gt: 1)
      se.note(Note.create(:"G#", 5), st: 600, gt: 600)
      se.step(480)

      se.step(480*2)
      se.step(240)
      se.note(Note.create(:"D#", 5), gt: 1)
      se.note(Note.create(:E, 5), st: 240, gt: 240)
      se.note(Note.create(:E, 5), st: 240, gt: 240)
      se.note(Note.create(:E, 5), st: 240, gt: 240)
      se.note(Note.create(:"G#", 5), gt: 1)
      se.note(Note.create(:A, 5), st: 240, gt: 240)
      se.note(Note.create(:"G#", 5), st: 120, gt: 120)
      se.note(Note.create(:"F#", 5), st: 240, gt: 240)
      se.note(Note.create(:E, 5), st: 240, gt: 240)
      se.note(Note.create(:"D#", 5), gt: 1)
      se.note(Note.create(:E, 5), st: 600, gt: 600)
      se.step(480)

      se.step(480*2)
      se.step(240)
      se.note(Note.create(:"D#", 5), gt: 1)
      se.note(Note.create(:E, 5), st: 240, gt: 240)
      se.note(Note.create(:E, 5), st: 240, gt: 240)
      se.note(Note.create(:E, 5), st: 240, gt: 240)
      se.note(Note.create(:"D#", 5), gt: 1)
      se.note(Note.create(:E, 5), st: 240, gt: 240)
      se.note(Note.create(:"D#", 5), st: 120, gt: 120)
      se.note(Note.create(:E, 5), st: 240, gt: 240)
      se.note(Note.create(:"F#", 5), st: 240, gt: 240)
      se.note(Note.create(:"F#", 5), gt: 1)
      se.note(Note.create(:"G#", 5), st: 480, gt: 480)
      se.step(120)

      se.note(Note.create(:"G#", 5), gt: 1)
      se.note(Note.create(:A, 5), st: 480, gt: 480)
      se.note(Note.create(:A, 5), gt: 1)
      se.note(Note.create(:B, 5), st: 360, gt: 360)
      se.note(Note.create(:E, 5), st: 360, gt: 360)
      se.note(Note.create(:E, 5), st: 480, gt: 480)
      se.note(Note.create(:"D#", 5), gt: 1)
      se.note(Note.create(:E, 5), st: 240, gt: 240)
      se.note(Note.create(:"F#", 5), st: 240, gt: 240)
      se.note(Note.create(:E, 5), st: 720, gt: 720)
      se.step(240)

      se.note(Note.create(:B, 4), st: 240, gt: 240)
      se.note(Note.create(:E, 5), st: 360, gt: 360)
      se.note(Note.create(:E, 5), gt: 1)
      se.note(Note.create(:"F#", 5), st: 360, gt: 360)
      se.note(Note.create(:"F#", 5), st: 2160, gt: 2160)

      se.step(480*4)

      se.complete
    }

    AudioInputStepEditor.new(synth, se)
  end

  def create_vocal2
    synth = MonoSynth.new(
      oscillators: [
        Oscillator.new(
          source: OscillatorSource::TriangleSquare.instance,
          tune_cents: ModulationValue.new(0.0)
            .add(@vocal_vibrato, depth: 30.0),
          uni_num: 2,
          uni_detune: 0.03,
          uni_stereo: 0.4,
        ),
      ],
      filter: Filter::Serial.new(
        Filter::BandPassFilter.new(freq: 2400, bandwidth: 2.0)
      ),
      amplifier: @default_amp,
      soundinfo: @soundinfo,
    )

    se = StepEditor::StGt.new(bpm: @soundinfo.bpm) {|se|
      se.step(480*4)

      se.step(480*2)
      se.step(240)
      se.note(Note.create(:B, 4), gt: 1)
      se.note(Note.create(:"C#", 5), st: 240, gt: 240)
      se.note(Note.create(:"C#", 5), st: 240, gt: 240)
      se.note(Note.create(:"C#", 5), st: 240, gt: 240)
      se.note(Note.create(:B, 4), gt: 1)
      se.note(Note.create(:"C#", 5), st: 240, gt: 240)
      se.note(Note.create(:B, 4), st: 120, gt: 120)
      se.note(Note.create(:"C#", 5), st: 240, gt: 240)
      se.note(Note.create(:"D#", 5), st: 240, gt: 240)
      se.note(Note.create(:"D#", 5), gt: 1)
      se.note(Note.create(:E, 5), st: 600, gt: 600)
      se.step(480)

      se.step(480*2)
      se.step(240)
      se.note(Note.create(:B, 4), gt: 1)
      se.note(Note.create(:"C#", 5), st: 240, gt: 240)
      se.note(Note.create(:"C#", 5), st: 240, gt: 240)
      se.note(Note.create(:"C#", 5), st: 240, gt: 240)
      se.note(Note.create(:E, 5), gt: 1)
      se.note(Note.create(:"F#", 5), st: 240, gt: 240)
      se.note(Note.create(:E, 5), st: 120, gt: 120)
      se.note(Note.create(:"D#", 5), st: 240, gt: 240)
      se.note(Note.create(:"C#", 5), st: 240, gt: 240)
      se.note(Note.create(:B, 4), gt: 1)
      se.note(Note.create(:"C#", 5), st: 600, gt: 600)
      se.step(480)

      se.step(480*2)
      se.step(240)
      se.note(Note.create(:B, 4), gt: 1)
      se.note(Note.create(:"C#", 5), st: 240, gt: 240)
      se.note(Note.create(:"C#", 5), st: 240, gt: 240)
      se.note(Note.create(:"C#", 5), st: 240, gt: 240)
      se.note(Note.create(:B, 4), gt: 1)
      se.note(Note.create(:"C#", 5), st: 240, gt: 240)
      se.note(Note.create(:B, 4), st: 120, gt: 120)
      se.note(Note.create(:"C#", 5), st: 240, gt: 240)
      se.note(Note.create(:"D#", 5), st: 240, gt: 240)
      se.note(Note.create(:"D#", 5), gt: 1)
      se.note(Note.create(:E, 5), st: 480, gt: 480)
      se.step(120)

      se.note(Note.create(:E, 5), gt: 1)
      se.note(Note.create(:"F#", 5), st: 480, gt: 480)
      se.note(Note.create(:"F#", 5), gt: 1)
      se.note(Note.create(:"G#", 5), st: 360, gt: 360)
      se.note(Note.create(:"C#", 5), st: 360, gt: 360)
      se.note(Note.create(:"C#", 5), st: 480, gt: 480)
      se.note(Note.create(:B, 4), gt: 1)
      se.note(Note.create(:"C#", 5), st: 240, gt: 240)
      se.note(Note.create(:"D#", 5), st: 240, gt: 240)
      se.note(Note.create(:B, 4), st: 720, gt: 720)
      se.step(240)

      se.note(Note.create(:"G#", 4), st: 240, gt: 240)
      se.note(Note.create(:"C#", 5), st: 360, gt: 360)
      se.note(Note.create(:"D#", 5), gt: 1)
      se.note(Note.create(:E, 5), st: 360, gt: 360)
      se.note(Note.create(:E, 5), st: 2160, gt: 2160)

      se.complete
    }

    AudioInputStepEditor.new(synth, se)
  end

  def create_chorus
    synth = PolySynth.new(
      oscillators: [
        Oscillator.new(
          source: OscillatorSource::TriangleSquare.instance,
          uni_num: 6,
          uni_detune: 0.12,
          uni_stereo: 1.0,
        ),
      ],
      filter: Filter::Serial.new(
        Filter::HighShelfFilter.new(freq: 1000, gain: 2.0)
      ),
      amplifier: @default_amp,
      soundinfo: @soundinfo,
    )

    se = StepEditor::StGt.new(bpm: @soundinfo.bpm) {|se|
      se.step(480*3)
      se.note(Note.create(:"G#", 4), gt: 480)
      se.note(Note.create(:B, 4), gt: 480)
      se.note(Note.create(:E, 5), st: 480, gt: 480)
      se.note(Note.create(:E, 5), gt: 1920)
      se.note(Note.create(:"G#", 5), gt: 1920)
      se.note(Note.create(:B, 5), st: 1920, gt: 1920)

      se.step(480*3)
      se.note(Note.create(:"G#", 4), gt: 480)
      se.note(Note.create(:B, 4), gt: 480)
      se.note(Note.create(:E, 5), st: 480, gt: 480)
      se.note(Note.create(:E, 5), gt: 720)
      se.note(Note.create(:"G#", 5), gt: 720)
      se.note(Note.create(:B, 5), st: 720, gt: 720)
      se.note(Note.create(:"F#", 5), gt: 120)
      se.note(Note.create(:A, 5), gt: 120)
      se.note(Note.create(:"C#", 6), st: 120, gt: 120)
      se.note(Note.create(:E, 5), gt: 1080)
      se.note(Note.create(:"G#", 5), gt: 1080)
      se.note(Note.create(:B, 5), st: 1080, gt: 1080)

      se.step(480*3)
      se.note(Note.create(:"G#", 4), gt: 480)
      se.note(Note.create(:B, 4), gt: 480)
      se.note(Note.create(:E, 5), st: 480, gt: 480)
      se.note(Note.create(:E, 5), gt: 1920)
      se.note(Note.create(:"G#", 5), gt: 1920)
      se.note(Note.create(:B, 5), st: 1920, gt: 1920)

      se.complete
    }

    AudioInputStepEditor.new(synth, se)
  end

  def create_chord
    synth = PolySynth.new(
      oscillators: [
        Oscillator.new(
          source: OscillatorSource::TriangleSquare.instance,
          sync: 2.0,
          uni_num: 4,
          uni_detune: 0.05,
          uni_stereo: 0.9,
        ),
      ],
      filter: Filter::Serial.new(
        Filter::HighShelfFilter.new(freq: 2100, gain: 2.0)
      ),
      amplifier: Amplifier.new(
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
      se.step(480)
      se.step(240)

      #se.note(Note.create(:E, 4), gt: 720)
      #se.note(Note.create(:"G#", 4), gt: 720)
      #se.note(Note.create(:B, 4), st: 1200, gt: 720)
      se.step(1200)

      se.note(Note.create(:B, 3), gt: 300)
      se.note(Note.create(:E, 4), gt: 300)
      se.note(Note.create(:"G#", 4), gt: 300)
      se.note(Note.create(:B, 4), st: 360, gt: 300)
      se.note(Note.create(:B, 3), gt: 120)
      se.note(Note.create(:E, 4), gt: 120)
      se.note(Note.create(:"G#", 4), gt: 120)
      se.note(Note.create(:B, 4), st: 120, gt: 120)
      se.step(480*3)

      se.note(Note.create(:B, 3), gt: 300)
      se.note(Note.create(:E, 4), gt: 300)
      se.note(Note.create(:A, 4), gt: 300)
      se.note(Note.create(:B, 4), st: 360, gt: 300)
      se.note(Note.create(:B, 3), gt: 120)
      se.note(Note.create(:E, 4), gt: 120)
      se.note(Note.create(:A, 4), gt: 120)
      se.note(Note.create(:B, 4), st: 120, gt: 120)
      se.step(480*3)

      se.note(Note.create(:B, 3), gt: 300)
      se.note(Note.create(:E, 4), gt: 300)
      se.note(Note.create(:"G#", 4), gt: 300)
      se.note(Note.create(:B, 4), st: 360, gt: 300)
      se.note(Note.create(:B, 3), gt: 120)
      se.note(Note.create(:E, 4), gt: 120)
      se.note(Note.create(:"G#", 4), gt: 120)
      se.note(Note.create(:B, 4), st: 120, gt: 120)
      se.step(480*3)

      se.note(Note.create(:B, 3), gt: 300)
      se.note(Note.create(:E, 4), gt: 300)
      se.note(Note.create(:A, 4), gt: 300)
      se.note(Note.create(:B, 4), st: 360, gt: 300)
      se.note(Note.create(:B, 3), gt: 120)
      se.note(Note.create(:E, 4), gt: 120)
      se.note(Note.create(:A, 4), gt: 120)
      se.note(Note.create(:B, 4), st: 240, gt: 120)
      se.note(Note.create(:B, 3), gt: 60)
      se.note(Note.create(:E, 4), gt: 60)
      se.note(Note.create(:A, 4), gt: 60)
      se.note(Note.create(:B, 4), st: 360, gt: 60)
      se.step(480*2)

      se.step(480*4)

      se.note(Note.create(:B, 3), gt: 300)
      se.note(Note.create(:E, 4), gt: 300)
      se.note(Note.create(:A, 4), gt: 300)
      se.note(Note.create(:B, 4), st: 360, gt: 300)
      se.note(Note.create(:B, 3), gt: 120)
      se.note(Note.create(:E, 4), gt: 120)
      se.note(Note.create(:A, 4), gt: 120)
      se.note(Note.create(:B, 4), st: 120, gt: 120)
      se.step(480*3)

      se.note(Note.create(:E, 4), gt: 300)
      se.note(Note.create(:"G#", 4), gt: 300)
      se.note(Note.create(:B, 4), st: 360, gt: 300)
      se.note(Note.create(:E, 4), gt: 120)
      se.note(Note.create(:"G#", 4), gt: 120)
      se.note(Note.create(:B, 4), st: 360, gt: 120)
      se.note(Note.create(:E, 4), gt: 480)
      se.note(Note.create(:A, 4), gt: 480)
      se.note(Note.create(:"C#", 5), st: 480, gt: 480)
      se.note(Note.create(:E, 4), gt: 240)
      se.note(Note.create(:"G#", 4), gt: 240)
      se.note(Note.create(:B, 4), st: 240, gt: 240)
      se.note(Note.create(:E, 4), gt: 240)
      se.note(Note.create(:A, 4), gt: 240)
      se.note(Note.create(:"C#", 5), st: 240, gt: 240)
      se.note(Note.create(:E, 4), gt: 960)
      se.note(Note.create(:G, 4), gt: 960)
      se.note(Note.create(:B, 4), gt: 960)
      se.note(Note.create(:E, 5), st: 960, gt: 960)

      se.note(Note.create(:E, 4), gt: 80)
      se.note(Note.create(:B, 4), st: 80, gt: 80)
      se.note(Note.create(:"F#", 4), gt: 80)
      se.note(Note.create(:"C#", 5), st: 80, gt: 80)
      se.note(Note.create(:"G#", 4), gt: 80)
      se.note(Note.create(:D, 5), st: 80, gt: 80)
      se.note(Note.create(:D, 4), gt: 360)
      se.note(Note.create(:A, 4), gt: 360)
      se.note(Note.create(:E, 5), st: 360, gt: 360)
      se.note(Note.create(:E, 4), gt: 240)
      se.note(Note.create(:B, 4), gt: 240)
      se.note(Note.create(:"F#", 5), st: 360, gt: 240)
      se.note(Note.create(:B, 3), gt: 240+480*4)
      se.note(Note.create(:E, 4), gt: 240+480*4)
      se.note(Note.create(:"F#", 4), gt: 240+480*4)
      se.note(Note.create(:B, 4), gt: 240+480*4)
      se.note(Note.create(:"F#", 5), st: 240+480*4, gt: 240+480*4)

      se.step(480*4)

      se.complete
    }

    AudioInputStepEditor.new(synth, se)
  end

  def create_slow_chord
    synth = PolySynth.new(
      oscillators: [
        Oscillator.new(
          source: OscillatorSource::SineSquare.instance,
          uni_num: 4,
          uni_detune: -0.23,
          uni_stereo: 1.0,
        ),
        Oscillator.new(
          source: OscillatorSource::SineSquare.instance,
          tune_semis: -12,
          uni_num: 4,
          uni_detune: -0.23,
          uni_stereo: 1.0,
        ),
      ],
      filter: Filter::Serial.new(
        Filter::HighPassFilter.new(freq: 400, q: Filter::DEFAULT_Q),
        Filter::LowShelfFilter.new(freq: 2200, gain: 1.0),
        Filter::LowPassFilter.new(
          freq: ModulationValue.new(50.0)
            .add(Modulation::Adsr.new(
              attack: Rate::SYNC_1_8D,
              attack_curve: Modulation::Curve::EaseIn2,
              hold: Rate::SYNC_1_16,
              decay: Rate::SYNC_1_16,
              sustain: 1.0,
              release: Rate.sec(10.0),
              release_curve: Modulation::Curve::EaseIn2,
            ), depth: 5000.0),
          q: Filter::DEFAULT_Q
        ),
      ),
      amplifier: Amplifier.new(
        volume: ModulationValue.new(1.0)
          .add(Modulation::Adsr.new(
            attack: Rate.sec(0.05),
            hold: Rate.sec(0.1),
            decay: Rate.sec(0.4),
            sustain: 0.8,
            release: Rate.sec(0.0)
          ), depth: 1.0),
      ),
      soundinfo: @soundinfo,
    )

    se = StepEditor::StGt.new(bpm: @soundinfo.bpm) {|se|
      se.step(480*4)
      se.step(480*4)
      se.step(480*4)
      se.step(480*4)

      se.step(480)
      se.note(Note.create(:B, 3), gt: 480)
      se.note(Note.create(:E, 4), gt: 480)
      se.note(Note.create(:A, 4), st: 480, gt: 480)
      se.step(480*2)

      se.note(Note.create(:"C#", 4), gt: 480*2, vel: 0.7)
      se.note(Note.create(:"G#", 4), gt: 480*2, vel: 0.7)
      se.note(Note.create(:B, 4), st: 480*2, gt: 480*2, vel: 0.7)
      se.step(480*2)

      se.step(480*3)
      se.note(Note.create(:B, 3), gt: 480)
      se.note(Note.create(:F, 4), gt: 480)
      se.note(Note.create(:A, 4), st: 480, gt: 480)

      se.step(480*4)

      se.complete
    }

    AudioInputStepEditor.new(synth, se)
  end

  def create_arpeggio1
    synth = PolySynth.new(
      oscillators: [
        Oscillator.new(
          source: OscillatorSource::SineTriangle.instance,
          uni_num: 2,
          uni_detune: 0.2,
          uni_stereo: 0.4,
        ),
      ],
      filter: Filter::Serial.new(
        Filter::HighPassFilter.new(freq: 500.0, q: Filter::DEFAULT_Q),
        Filter::HighShelfFilter.new(freq: 2000.0, q: Filter::DEFAULT_Q, gain: 1.0),
        Filter::HighShelfFilter.new(freq: 10000.0, q: 0.3, gain: 1.0),
      ),
      amplifier: Amplifier.new(
        volume: ModulationValue.new(1.0)
          .add(Modulation::Adsr.new(
            attack: Rate.sec(0.0),
            hold: Rate.sec(0.0),
            decay: Rate.sec(0.0),
            sustain: 1.0,
            release: Rate.sec(0.1)
          ), depth: 1.0),
      ),
      soundinfo: @soundinfo,
    )

    se = StepEditor::StGt.new(bpm: @soundinfo.bpm) {|se|
      se.step(480*4)

      3.times {|_|
        se.step(480*2)
        se.step(240)

        se.note(Note.create(:"D#", 4), st: 120, gt: 120)
        se.note(Note.create(:E, 4), st: 120, gt: 120)
        se.note(Note.create(:B, 4), st: 120, gt: 120)
        se.note(Note.create(:E, 5), st: 120, gt: 120)
        se.step(240)

        se.step(480*4)
      }

      se.complete
    }

    AudioInputStepEditor.new(synth, se)
  end

  def create_arpeggio2
    synth = PolySynth.new(
      oscillators: [
        Oscillator.new(
          source: OscillatorSource::TriangleSawtooth.instance,
          pan: -0.6,
          tune_semis: 0,
        ),
        Oscillator.new(
          source: OscillatorSource::TriangleSawtooth.instance,
          pan: 0.6,
          tune_semis: 12,
        ),
      ],
      filter: Filter::Serial.new(
        Filter::BandPassFilter.new(freq: 10000.0, bandwidth: 4.0)
      ),
      amplifier: @default_amp,
      soundinfo: @soundinfo,
    )

    se = StepEditor::StGt.new(bpm: @soundinfo.bpm) {|se|
      se.step(480*4)

      se.step(480*4)
      se.step(480*2)

      se.note(Note.create(:E, 4), st: 120, gt: 120)
      se.note(Note.create(:"D#", 4), st: 240, gt: 120)
      se.note(Note.create(:B, 3), st: 240, gt: 120)
      se.note(Note.create(:"G#", 3), st: 360, gt: 240)

      se.complete
    }

    AudioInputStepEditor.new(synth, se)
  end

  def create_bass
    synth = PolySynth.new(
      oscillators: [
        Oscillator.new(
          source: OscillatorSource::SawtoothSquare.instance,
        ),
      ],
      filter: Filter::Serial.new(
        Filter::LowShelfFilter.new(freq: 600.0, gain: 2.0)
      ),
      amplifier: @default_amp,
      soundinfo: @soundinfo,
    )

    se = StepEditor::StGt.new(bpm: @soundinfo.bpm) {|se|
      se.step(480)
      se.step(240)

      se.note(Note.create(:E, 2), st: 480, gt: 480)
      se.note(Note.create(:E, 2), st: 120, gt: 120)
      se.note(Note.create(:E, 2), st: 120, gt: 120)
      se.note(Note.create(:D, 2), st: 240, gt: 240)
      se.note(Note.create(:E, 2), st: 240, gt: 240)

      se.note(Note.create(:A, 1), st: 360, gt: 240)
      se.note(Note.create(:A, 1), st: 240, gt: 240)
      se.note(Note.create(:A, 2), st: 120, gt: 120)
      se.note(Note.create(:E, 2), st: 120, gt: 120)
      se.note(Note.create(:B, 1), st: 120, gt: 120)
      se.note(Note.create(:A, 1), st: 480*2, gt: 480)

      se.note(Note.create(:B, 1), st: 240, gt: 240)
      se.note(Note.create(:B, 2), st: 360, gt: 240)
      se.note(Note.create(:B, 2), st: 120, gt: 120)
      se.note(Note.create(:B, 1), st: 240, gt: 240)
      se.note(Note.create(:"C#", 2), st: 240, gt: 240)
      se.note(Note.create(:"G#", 2), st: 240, gt: 120)
      se.note(Note.create(:"C#", 2), st: 480, gt: 480)

      se.note(Note.create(:A, 1), st: 360, gt: 240)
      se.note(Note.create(:A, 1), st: 240, gt: 240)
      se.note(Note.create(:A, 2), st: 120, gt: 120)
      se.note(Note.create(:E, 2), st: 120, gt: 120)
      se.note(Note.create(:B, 1), st: 120, gt: 120)
      se.note(Note.create(:A, 1), st: 480*2, gt: 480*2)

      se.note(Note.create(:B, 1), st: 240, gt: 240)
      se.note(Note.create(:B, 2), st: 360, gt: 240)
      se.note(Note.create(:B, 2), st: 120, gt: 120)
      se.note(Note.create(:B, 1), st: 240, gt: 240)
      se.note(Note.create(:"C#", 2), st: 480, gt: 480)
      se.note(Note.create(:B, 1), st: 160, gt: 160)
      se.note(Note.create(:B, 1), st: 160, gt: 160)
      se.note(Note.create(:B, 1), st: 160, gt: 160)

      se.note(Note.create(:A, 1), st: 840, gt: 840)
      se.note(Note.create(:A, 1), st: 120, gt: 120)
      se.note(Note.create(:A, 2), st: 480, gt: 480)
      se.note(Note.create(:A, 1), st: 480, gt: 480)

      se.note(Note.create(:B, 1), st: 240, gt: 240)
      se.note(Note.create(:B, 2), st: 360, gt: 240)
      se.note(Note.create(:A, 2), st: 120, gt: 120)
      se.note(Note.create(:B, 1), st: 240, gt: 240)
      se.note(Note.create(:"C#", 2), st: 480, gt: 480)
      se.note(Note.create(:B, 1), st: 480, gt: 480)

      se.note(Note.create(:A, 1), st: 720, gt: 480)
      se.note(Note.create(:B, 1), st: 960, gt: 960)
      se.note(Note.create(:C, 2), st: 1200, gt: 1200)
      se.note(Note.create(:D, 2), st: 360, gt: 360)
      se.note(Note.create(:D, 2), st: 360, gt: 240)

      se.note(Note.create(:B, 1), st: 480, gt: 480)
      se.note(Note.create(:B, 1), st: 240, gt: 240)
      se.note(Note.create(:B, 1), st: 120, gt: 120)
      se.note(Note.create(:B, 2), st: 120, gt: 120)
      se.note(Note.create(:B, 1), st: 240, gt: 240)
      se.note(Note.create(:B, 1), st: 240, gt: 240)
      se.note(Note.create(:B, 1), st: 240, gt: 240)
      se.note(Note.create(:B, 1), st: 240, gt: 240)
      se.note(Note.create(:B, 1), st: 240, gt: 240)

      se.step(480*4)

      se.complete
    }

    AudioInputStepEditor.new(synth, se)
  end

  def create_dub1
    lfo1 = Modulation::Lfo.new(
      shape: Shape::Sine,
      delay: Rate.sec(0.0),
      attack: Rate.sec(0.0),
      attack_curve: Modulation::Curve::EaseIn,
      phase: 0.0,
      rate: Rate::SYNC_1_128
    )
    adsr2 = Modulation::Adsr.new(
      attack: Rate.sec(0.1),
      attack_curve: Modulation::Curve::Straight,
      decay: Rate.sec(0.0),
      sustain: 1.0,
      release: Rate.sec(0.1),
      release_curve: Modulation::Curve::EaseOut,
    )

    synth = PolySynth.new(
      oscillators: [
        Oscillator.new(
          source: OscillatorSource::Sawtooth.instance,
          volume: ModulationValue.new(1.0)
            .add(lfo1, depth: 1.0),
          tune_semis: ModulationValue.new(0.0)
            .add(adsr2, depth: 12.0),
          sync: ModulationValue.new(0.0)
            .add(adsr2, depth: 10.0),
        ),
        Oscillator.new(
          source: OscillatorSource::Sawtooth.instance,
          volume: ModulationValue.new(1.0)
            .add(adsr2, depth: 1.0),
          tune_semis: ModulationValue.new(-12.0)
            .add(adsr2, depth: 12.0),
          sync: ModulationValue.new(0.0)
            .add(lfo1, depth: 10.0),
        ),
      ],
      filter: Filter::Serial.new(
        Filter::HighPassFilter.new(freq: 1000.0, q: Filter::DEFAULT_Q),
        Filter::HighShelfFilter.new(freq: 4000.0, q: Filter::DEFAULT_Q, gain: 0.5),
      ),
      amplifier: Amplifier.new(
        volume: ModulationValue.new(1.0)
          .add(Modulation::Adsr.new(
            attack: Rate.sec(0.0),
            hold: Rate.sec(0.0),
            decay: Rate.sec(0.0),
            sustain: 1.0,
            release: Rate.sec(0.3)
          ), depth: 1.0),
      ),
      quality: Quality::HIGH,
      soundinfo: @soundinfo,
    )


    se = StepEditor::StGt.new(bpm: @soundinfo.bpm) {|se|
      se.step(480*4)

      se.step(480*2)
      se.note(Note.create(:"C#", 5), st: 480, gt: 480)
      se.step(480)
      se.step(480*4)

      se.step(480*2)
      se.note(Note.create(:"C#", 5), st: 480, gt: 480)
      se.step(480)

      se.step(480*2)
      se.note(Note.create(:"C#", 5), st: 480, gt: 480)
      se.step(480)

      se.step(480*2)
      se.note(Note.create(:"C#", 5), st: 480, gt: 480)
      se.step(480)

      se.step(480*2)
      se.note(Note.create(:"C#", 5), st: 480, gt: 480)
      se.step(480)

      se.complete
    }

    AudioInputStepEditor.new(synth, se)
  end

  def create_dub2
    lfo1 = Modulation::Lfo.new(
      shape: Shape::Sine,
      delay: Rate.sec(0.0),
      attack: Rate.sec(0.0),
      attack_curve: Modulation::Curve::EaseIn,
      phase: 0.0,
      rate: Rate::SYNC_1_64
    )
    adsr1 = Modulation::Adsr.new(
      attack: Rate.sec(0.1),
      attack_curve: Modulation::Curve::EaseOut,
      decay: Rate.sec(0.0),
      sustain: 1.0,
      release: Rate.sec(10.0),
      release_curve: Modulation::Curve::EaseIn,
    )

    synth = PolySynth.new(
      oscillators: [
        Oscillator.new(
          source: OscillatorSource::Sawtooth.instance,
          volume: ModulationValue.new(1.0)
            .add(lfo1, depth: 1.0),
          tune_semis: ModulationValue.new(3.0)
            .add(adsr1, depth: -3.0),
          #sync: ModulationValue.new(0.0)
          #  .add(adsr1, depth: 6.0),
        ),
        Oscillator.new(
          source: OscillatorSource::Sawtooth.instance,
          volume: ModulationValue.new(1.0)
            .add(lfo1, depth: 1.0),
          tune_semis: ModulationValue.new(3.0-12.0)
            .add(adsr1, depth: -3.0),
          sync: ModulationValue.new(0.0)
            .add(lfo1, depth: 6.0),
        ),
        Oscillator.new(
          source: OscillatorSource::FormantVocoder.new(
            vowels: [:i, :o],
            pronunciation: ModulationValue.new(0.0)
              .add(adsr1, depth: 1.0),
          ),
          volume: ModulationValue.new(1.0)
            .add(lfo1, depth: 1.0),
          tune_semis: ModulationValue.new(3.0-12.0)
            .add(adsr1, depth: -3.0),
        ),
      ],
      filter: Filter::Serial.new(
        Filter::HighPassFilter.new(freq: 500.0, q: Filter::DEFAULT_Q),
        Filter::PeakingFilter.new(freq: 2000, bandwidth: 4.0, gain: 15),
      ),
      amplifier: @default_amp,
      quality: Quality::HIGH,
      soundinfo: @soundinfo,
    )

    se = StepEditor::StGt.new(bpm: @soundinfo.bpm) {|se|
      se.step(480*4)

      se.step(480*3)
      se.note(Note.create(:B, 3), st: 480, gt: 480)
      se.step(480*4)

      se.step(480*3)
      se.note(Note.create(:B, 3), st: 480, gt: 480)

      se.step(480*3)
      se.note(Note.create(:B, 3), st: 160, gt: 120)
      se.note(Note.create(:B, 3), st: 160, gt: 120)
      se.note(Note.create(:B, 3), st: 160, gt: 120)

      se.step(480*3)
      se.note(Note.create(:B, 3), st: 480, gt: 480)

      se.step(480*3)
      se.note(Note.create(:B, 3), st: 480, gt: 480)

      se.complete
    }

    AudioInputStepEditor.new(synth, se)
  end

  def create_white_noise
    freq_adsr = Modulation::Adsr.new(
      attack: Rate::SYNC_3,
      attack_curve: Modulation::Curve::EaseIn2,
      decay: Rate.sec(0.0),
      sustain: 1.0,
      release: Rate.sec(10.0),
      release_curve: Modulation::Curve::EaseIn2,
    )

    synth = PolySynth.new(
      oscillators: [
        Oscillator.new(
          source: OscillatorSource::WhiteNoise.instance,
          pan: -1.0,
        ),
        Oscillator.new(
          source: OscillatorSource::WhiteNoise.instance,
          pan: 1.0,
        ),
      ],
      filter: Filter::Serial.new(
        Filter::BandPassFilter.new(
          freq: ModulationValue.new(100)
            .add(freq_adsr, depth: 20000),
          bandwidth: 1.0)
      ),
      amplifier: Amplifier.new(
        volume: ModulationValue.new(1.0)
          .add(Modulation::Adsr.new(
            attack: Rate::SYNC_3,
            attack_curve: Modulation::Curve::EaseOut,
            decay: Rate.sec(0.0),
            sustain: 0.8,
            release: Rate.sec(0.3)
          ), depth: 1.0),
      ),
      soundinfo: @soundinfo,
    )

    se = StepEditor::StGt.new(bpm: @soundinfo.bpm) {|se|
      se.step(480*4*7)
      se.note(Note.create(:A, 4), st: 480*4*3, gt: 480*4*3)
      se.step(480*4)

      se.complete
    }

    AudioInputStepEditor.new(synth, se)
  end

  def mixer
    bus1 = AudioBus.new
    bus2 = AudioBus.new

    @inputs[:vocal1]
      .send_to(bus1, gain: -14.0, pan: 0.0)

    @inputs[:vocal2]
      .send_to(bus1, gain: -16.0, pan: 0.0)

    @inputs[:chorus]
      .fx(Chorus.new(@soundinfo, depth: 100, rate: 4))
      .send_to(bus1, gain: -16.0, pan: 0.0)

    @inputs[:chord]
      .fx(Delay.new(@soundinfo, time: Rate::SYNC_1_8, level: -10.0, feedback: -16.0))
      .send_to(bus1, gain: -16.0, pan: 0.1)

    @inputs[:slow_chord]
      .fx(Phaser.new(@soundinfo, rate: Rate.freq(1.4), depth: 3.5, freq: 2123, dry: -6, wet: -6))
      .fx(Phaser.new(@soundinfo, rate: Rate.freq(1.83), depth: 3.5, freq: 1357, dry: -6, wet: -6))
      .send_to(bus2, gain: -10.0, pan: 0.1)


    @inputs[:arpeggio1]
      .send_to(bus1, gain: -10.0, pan: -0.4)


    @inputs[:arpeggio2]
      .fx(Phaser.new(@soundinfo, rate: Rate.freq(1.4), depth: 3.5, freq: 800, dry: 0.5, wet: 0.5))
      .send_to(bus1, gain: -14.0, pan: 0.3)


    @inputs[:bass]
      .send_to(bus2, gain: -20.0, pan: 0.0)


    @inputs[:dub1]
      .send_to(bus2, gain: -20.0, pan: -0.6)

    @inputs[:dub2]
      .send_to(bus2, gain: -30.0, pan: 0.6)

    @inputs[:white_noise]
      .send_to(bus2, gain: -18.0, pan: 0.0)


    bus1
      .fx(Compressor.new(threshold: 0.5, ratio: 0.8))
      .fx(SchroederReverb.new(@soundinfo, dry: -1.0, wet: -20.0))
      .send_to(@output, gain: -8.0)

    bus2
      .fx(Compressor.new(threshold: 0.5, ratio: 0.8))
      .send_to(@output, gain: -10.0)

    @inputs[:drum]
      .send_to(@output, gain: -1.0)



    conductor = Conductor.new(
      input: @inputs.values,
      output: @output
    )
    conductor.connect
    conductor.join
  end
end


KiraPower.new.mixer
