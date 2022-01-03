$LOAD_PATH << File.dirname(__FILE__) + "/../lib"
$LOAD_PATH << File.dirname(__FILE__) + "/../../ruby-audio_stream/lib"

require 'synthesizer'
require 'audio_stream'

include AudioStream
include AudioStream::Fx
include Synthesizer

class ChronoTrigger
  def initialize
    @soundinfo = SoundInfo.new(
      channels: 2,
      samplerate: 44100,
      window_size: 1024,
      format: RubyAudio::FORMAT_WAV|RubyAudio::FORMAT_PCM_16,
      bpm: 130
    )

    @quality = Quality::HIGH

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
      oboe: create_oboe,
      string: create_string,
      bass: create_bass,
      snare: create_snare,
      timpani: create_timpani,
      piccolo: create_piccolo,
    }

    #@output = AudioOutput.device(soundinfo: @soundinfo)
    @output = AudioOutput.file(File.dirname(__FILE__)+"/output_chronotrigger.wav", soundinfo: @soundinfo)
  end

  def create_oboe
    op1 = Operator.new(
      source: OscillatorSource::Sine.instance,
      level: Decibel.dx7(99).mag,
      fixed_freq: nil,
      ratio_freq: 2.0,
      envelope: Modulation::Dx7Envelope.new(
        r1: 60, r2: 0,  r3: 12, r4: 66,
        l1: 99, l2: 90, l3: 97, l4: 0
      ),
      phase: 0.0,
      pmd: 0.0,
      amd: 0.0,
    )

    op2 = Operator.new(
      source: OscillatorSource::Sine.instance,
      level: Decibel.dx7(72).mag,
      fixed_freq: nil,
      ratio_freq: 1.0,
      envelope: Modulation::Dx7Envelope.new(
        r1: 95, r2: 95, r3: 0,  r4: 0,
        l1: 99, l2: 96, l3: 89, l4: 0
      ),
      phase: 0.0,
      pmd: 0.0,
      amd: 0.0,
    )

    op3 = Operator.new(
      source: OscillatorSource::Sine.instance,
      level: Decibel.dx7(89).mag,
      fixed_freq: nil,
      ratio_freq: 1.0,
      envelope: Modulation::Dx7Envelope.new(
        r1: 98, r2: 87, r3: 0,  r4: 0,
        l1: 93, l2: 90, l3: 0,  l4: 0
      ),
      phase: 0.0,
      pmd: 0.0,
      amd: 0.0,
    )

    op4 = Operator.new(
      source: OscillatorSource::Sine.instance,
      level: Decibel.dx7(67).mag,
      fixed_freq: nil,
      ratio_freq: 1.0,
      envelope: Modulation::Dx7Envelope.new(
        r1: 95, r2: 92, r3: 28, r4: 60,
        l1: 99, l2: 90, l3: 0,  l4: 0
      ),
      phase: 0.0,
      pmd: 0.0,
      amd: 0.0,
    )

    op5 = Operator.new(
      source: OscillatorSource::Sine.instance,
      level: Decibel.dx7(99).mag,
      fixed_freq: nil,
      ratio_freq: 0.5,
      envelope: Modulation::Dx7Envelope.new(
        r1: 0,  r2: 70, r3: 97, r4: 0,
        l1: 99, l2: 65, l3: 60, l4: 0
      ),
      phase: 0.0,
      pmd: 0.0,
      amd: 0.0,
    )

    op6 = Operator.new(
      source: OscillatorSource::Sine.instance,
      level: Decibel.dx7(47).mag,
      fixed_freq: nil,
      ratio_freq: 0.995,
      envelope: Modulation::Dx7Envelope.new(
        r1: 73, r2: 70, r3: 60, r4: 0,
        l1: 99, l2: 99, l3: 97, l4: 0
      ),
      phase: 0.0,
      pmd: 0.0,
      amd: 0.0,
    )

    synth = FmSynth.new(
      operators: {
        op1: op1,
        op2: op2,
        op3: op3,
        op4: op4,
        op5: op5,
        op6: op6,
      },
      algorithm: Algorithm.new
        .add(:op2, :op1)
        .add(:op3, :op1)
        .add(:op6, :op5, :op4, :op1),
      soundinfo: @soundinfo,
      quality: @quality,
    ).build


    se = StepEditor::StGt.new(bpm: @soundinfo.bpm) {|se|
      octave = 1
      se.step(240)

      2.times {
        se.note(Note.create(:B, 2+octave), st: 240, gt: 240)
        se.note(Note.create(:E, 3+octave), st: 360, gt: 360)
        se.note(Note.create(:"F#", 3+octave), st: 360, gt: 360)
        se.note(Note.create(:G, 3+octave), st: 240, gt: 240)
        se.note(Note.create(:B, 2+octave), st: 360, gt: 360)
        se.note(Note.create(:"F#", 3+octave), st: 360, gt: 360)
        se.note(Note.create(:D, 3+octave), st: 1440, gt: 1200)

        se.note(Note.create(:G, 2+octave), st: 120, gt: 120)
        se.note(Note.create(:A, 2+octave), st: 120, gt: 120)
        se.note(Note.create(:B, 2+octave), st: 120, gt: 120)
        se.note(Note.create(:A, 3+octave), st: 360, gt: 360)
        se.note(Note.create(:B, 3+octave), st: 360, gt: 360)
        se.note(Note.create(:B, 3+octave), st: 360, gt: 360)
        se.note(Note.create(:A, 3+octave), st: 120, gt: 120)
        se.note(Note.create(:"G#", 3+octave), st: 120, gt: 120)
        se.note(Note.create(:E, 3+octave), st: 2640, gt: 2400)
      }

      se.note(Note.create(:E, 3+octave), st: 120, gt: 120)
      se.note(Note.create(:"F#", 3+octave), st: 120, gt: 120)
      se.note(Note.create(:G, 3+octave), st: 960, gt: 960)
      se.note(Note.create(:A, 3+octave), st: 960, gt: 960)
      se.note(Note.create(:B, 3+octave), st: 720, gt: 720)
      se.note(Note.create(:C, 4+octave), st: 480, gt: 280)
      se.note(Note.create(:C, 4+octave), st: 480, gt: 280)
      se.note(Note.create(:"C#", 4+octave), st: 60, gt: 60)
      se.note(Note.create(:D, 4+octave), st: 420, gt: 300)
      se.note(Note.create(:D, 4+octave), st: 480, gt: 480)
      se.note(Note.create(:"C#", 4+octave), st: 120, gt: 120)
      se.note(Note.create(:C, 4+octave), st: 120, gt: 120)
      se.note(Note.create(:B, 3+octave), st: 2640, gt: 2400)

      se.note(Note.create(:D, 3+octave), st: 240, gt: 240)
      se.note(Note.create(:E, 3+octave), st: 960, gt: 960)
      se.note(Note.create(:G, 3+octave), st: 960, gt: 960)
      se.note(Note.create(:A, 3+octave), st: 960, gt: 960)
      se.note(Note.create(:G, 3+octave), st: 960, gt: 960)

      se.note(Note.create(:"F#", 3+octave), st: 120, gt: 120)
      se.note(Note.create(:E, 3+octave), st: 120, gt: 120)
      se.note(Note.create(:"F#", 3+octave), st: 1200, gt: 240)
      se.note(Note.create(:"F#", 3+octave), st: 120, gt: 120)
      se.note(Note.create(:E, 3+octave), st: 120, gt: 120)
      se.note(Note.create(:"F#", 3+octave), st: 240, gt: 240)

      se.step(480)
      se.complete
    }

    AudioInputStepEditor.new(synth, se)
  end

  def create_string
    op1 = Operator.new(
      source: OscillatorSource::Sine.instance,
      level: Decibel.dx7(99).mag,
      fixed_freq: 1.25893,
      ratio_freq: nil,
      envelope: Modulation::Dx7Envelope.new(
        r1: 41, r2: 25, r3: 22, r4: 45,
        l1: 99, l2: 97, l3: 86, l4: 0
      ),
      phase: 0.0,
      pmd: 0.0,
      amd: 0.0,
    )

    op2 = Operator.new(
      source: OscillatorSource::Sine.instance,
      level: Decibel.dx7(75).mag,
      fixed_freq: nil,
      ratio_freq: 2.0,
      envelope: Modulation::Dx7Envelope.new(
        r1: 99, r2: 0,  r3: 0,  r4: 30,
        l1: 99, l2: 98, l3: 97, l4: 0
      ),
      phase: 0.0,
      pmd: 0.0,
      amd: 0.0,
    )

    op3 = Operator.new(
      source: OscillatorSource::Sine.instance,
      level: Decibel.dx7(99).mag,
      fixed_freq: nil,
      ratio_freq: 2.0,
      envelope: Modulation::Dx7Envelope.new(
        r1: 53, r2: 18, r3: 17, r4: 56,
        l1: 99, l2: 95, l3: 92, l4: 0
      ),
      phase: 0.0,
      pmd: 0.0,
      amd: 0.0,
    )

    op4 = Operator.new(
      source: OscillatorSource::Sine.instance,
      level: Decibel.dx7(87).mag,
      fixed_freq: nil,
      ratio_freq: 2.0,
      envelope: Modulation::Dx7Envelope.new(
        r1: 61, r2: 30, r3: 0,  r4: 35,
        l1: 99, l2: 98, l3: 90, l4: 0
      ),
      phase: 0.0,
      pmd: 0.0,
      amd: 0.0,
    )

    op5 = Operator.new(
      source: OscillatorSource::Sine.instance,
      level: Decibel.dx7(75).mag,
      fixed_freq: nil,
      ratio_freq: 8.0,
      envelope: Modulation::Dx7Envelope.new(
        r1: 99, r2: 49, r3: 55, r4: 46,
        l1: 99, l2: 90, l3: 80, l4: 0
      ),
      phase: 0.0,
      pmd: 0.0,
      amd: 0.0,
    )

    op6 = Operator.new(
      source: OscillatorSource::Sine.instance,
      #level: Decibel.dx7(44).mag,
      level: Decibel.dx7(10).mag,
      fixed_freq: 2041.74,
      ratio_freq: nil,
      envelope: Modulation::Dx7Envelope.new(
        r1: 73, r2: 70, r3: 60, r4: 0,
        l1: 99, l2: 99, l3: 97, l4: 0
      ),
      phase: 0.0,
      pmd: 0.0,
      amd: 0.0,
    )

    synth = FmSynth.new(
      operators: {
        op1: op1,
        op2: op2,
        op3: op3,
        op4: op4,
        op5: op5,
        op6: op6,
      },
      algorithm: Algorithm.new
        .add(:op2, :op1)
        .add(:op6, :op5, :op4, :op3),
      soundinfo: @soundinfo,
      quality: @quality,
    ).build


    se = StepEditor::StGt.new(bpm: @soundinfo.bpm) {|se|
      se.step(480)

      chord = ->(notes, st) {
        notes += notes.map {|note|
          Note.new(note.num - 12)
        }
        notes.each_with_index {|note, i|
          st1 = notes.length==i+1 ? st : 0
          se.note(note, st: st1, gt: 240)
        }
      }

      chord[[Note.create(:E, 3), Note.create(:G, 3)], 720]
      chord[[Note.create(:E, 3), Note.create(:G, 3)], 960]
      chord[[Note.create(:D, 3), Note.create(:"F#", 3)], 240]
      chord[[Note.create(:E, 3), Note.create(:G, 3)], 720]
      chord[[Note.create(:E, 3), Note.create(:G, 3)], 960]

      chord[[Note.create(:D, 3), Note.create(:"F#", 3)], 240]
      chord[[Note.create(:"C#", 3), Note.create(:E, 3)], 720]
      chord[[Note.create(:"C#", 3), Note.create(:E, 3)], 960]
      chord[[Note.create(:"C#", 3), Note.create(:E, 3)], 240]
      chord[[Note.create(:E, 3), Note.create(:A, 3)], 720]
      chord[[Note.create(:E, 3), Note.create(:A, 3)], 960]

      chord[[Note.create(:D, 3), Note.create(:"F#", 3)], 240]
      chord[[Note.create(:E, 3), Note.create(:G, 3)], 720]
      chord[[Note.create(:E, 3), Note.create(:G, 3)], 960]
      chord[[Note.create(:D, 3), Note.create(:"F#", 3)], 240]
      chord[[Note.create(:E, 3), Note.create(:G, 3)], 720]
      chord[[Note.create(:E, 3), Note.create(:G, 3)], 960]

      chord[[Note.create(:D, 3), Note.create(:"F#", 3)], 240]
      chord[[Note.create(:"C#", 3), Note.create(:E, 3)], 720]
      chord[[Note.create(:"C#", 3), Note.create(:E, 3)], 960]
      chord[[Note.create(:"C#", 3), Note.create(:E, 3)], 240]
      chord[[Note.create(:E, 3), Note.create(:A, 3)], 720]
      chord[[Note.create(:E, 3), Note.create(:A, 3)], 960]

      chord[[Note.create(:E, 3), Note.create(:A, 3)], 240]
      chord[[Note.create(:E, 3), Note.create(:G, 3)], 720]
      chord[[Note.create(:E, 3), Note.create(:G, 3)], 960]
      chord[[Note.create(:D, 3), Note.create(:"F#", 3)], 240]
      chord[[Note.create(:E, 3), Note.create(:G, 3)], 720]
      chord[[Note.create(:E, 3), Note.create(:G, 3)], 960]

      chord[[Note.create(:D, 3), Note.create(:"F#", 3)], 240]
      chord[[Note.create(:D, 3), Note.create(:"F#", 3)], 720]
      chord[[Note.create(:D, 3), Note.create(:"F#", 3)], 960]
      chord[[Note.create(:E, 3), Note.create(:G, 3)], 240]
      chord[[Note.create(:D, 3), Note.create(:"F#", 3)], 720]
      chord[[Note.create(:D, 3), Note.create(:"F#", 3)], 960]

      chord[[Note.create(:D, 3), Note.create(:"F#", 3)], 240]
      chord[[Note.create(:E, 3), Note.create(:G, 3)], 720]
      chord[[Note.create(:E, 3), Note.create(:G, 3)], 960]
      chord[[Note.create(:E, 3), Note.create(:G, 3)], 240]
      chord[[Note.create(:F, 3), Note.create(:A, 3)], 720]
      chord[[Note.create(:F, 3), Note.create(:A, 3)], 960]

      chord[[Note.create(:F, 3), Note.create(:A, 3)], 240]
      chord[[Note.create(:D, 3), Note.create(:"F#", 3)], 1440]
      chord[[Note.create(:D, 3), Note.create(:"F#", 3)], 480]

      se.step(480)
      se.complete
    }

    AudioInputStepEditor.new(synth, se)
  end

  def create_bass
    op1 = Operator.new(
      source: OscillatorSource::Sine.instance,
      level: Decibel.dx7(99).mag,
      fixed_freq: nil,
      ratio_freq: 0.5,
      envelope: Modulation::Dx7Envelope.new(
        r1: 95, r2: 62, r3: 17, r4: 58,
        l1: 99, l2: 95, l3: 32, l4: 0
      ),
      phase: 0.0,
      pmd: 0.0,
      amd: 0.0,
    )

    op2 = Operator.new(
      source: OscillatorSource::Sine.instance,
      level: Decibel.dx7(80).mag,
      fixed_freq: nil,
      ratio_freq: 0.5,
      envelope: Modulation::Dx7Envelope.new(
        r1: 99, r2: 20, r3: 0,  r4: 0,
        l1: 99, l2: 0,  l3: 0,  l4: 0
      ),
      phase: 0.0,
      pmd: 0.0,
      amd: 0.0,
    )

    op3 = Operator.new(
      source: OscillatorSource::Sine.instance,
      level: Decibel.dx7(99).mag,
      fixed_freq: nil,
      ratio_freq: 2.0,
      envelope: Modulation::Dx7Envelope.new(
        r1: 88, r2: 96, r3: 32, r4: 30,
        l1: 79, l2: 65, l3: 0,  l4: 0
      ),
      phase: 0.0,
      pmd: 0.0,
      amd: 0.0,
    )

    op4 = Operator.new(
      source: OscillatorSource::Sine.instance,
      level: Decibel.dx7(93).mag,
      fixed_freq: nil,
      ratio_freq: 5.0,
      envelope: Modulation::Dx7Envelope.new(
        r1: 90, r2: 42, r3: 7,  r4: 55,
        l1: 90, l2: 30, l3: 0,  l4: 0
      ),
      phase: 0.0,
      pmd: 0.0,
      amd: 0.0,
    )

    op5 = Operator.new(
      source: OscillatorSource::Sine.instance,
      level: Decibel.dx7(62).mag,
      fixed_freq: nil,
      ratio_freq: 0.5,
      envelope: Modulation::Dx7Envelope.new(
        r1: 99, r2: 0,  r3: 0,  r4: 0,
        l1: 99, l2: 0,  l3: 0,  l4: 0
      ),
      phase: 0.0,
      pmd: 0.0,
      amd: 0.0,
    )

    op6 = Operator.new(
      source: OscillatorSource::Sine.instance,
      level: Decibel.dx7(85).mag,
      fixed_freq: nil,
      ratio_freq: 9.0,
      envelope: Modulation::Dx7Envelope.new(
        r1: 94, r2: 56, r3: 24, r4: 55,
        l1: 93, l2: 28, l3: 0,  l4: 0
      ),
      phase: 0.0,
      pmd: 0.0,
      amd: 0.0,
    )

    synth = FmSynth.new(
      operators: {
        op1: op1,
        op2: op2,
        op3: op3,
        op4: op4,
        #op5: op5,
        #op6: op6,
      },
      algorithm: Algorithm.new
        .add(:op2, :op1)
        .add(:op4, :op3, :op1),
        #.add(:op6, :op5, :op1),
      soundinfo: @soundinfo,
      quality: @quality,
    ).build


    se = StepEditor::StGt.new(bpm: @soundinfo.bpm) {|se|
      octave = 1
      se.step(480)

      root_measure = ->(note) {
        se.note(note, st: 480, gt: 480)
        se.note(note, st: 240, gt: 240)
        se.note(note, st: 480, gt: 480)
        se.note(note, st: 240, gt: 240)
        se.note(note, st: 240, gt: 240)
        se.note(note, st: 240, gt: 240)
      }

      root_measure[Note.create(:A, 1+octave)]
      root_measure[Note.create(:A, 1+octave)]
      root_measure[Note.create(:"F#", 1+octave)]
      root_measure[Note.create(:"F#", 1+octave)]
      root_measure[Note.create(:A, 1+octave)]
      root_measure[Note.create(:A, 1+octave)]
      root_measure[Note.create(:"F#", 1+octave)]
      root_measure[Note.create(:"F#", 1+octave)]
      root_measure[Note.create(:F, 1+octave)]
      root_measure[Note.create(:F, 1+octave)]
      root_measure[Note.create(:E, 1+octave)]
      root_measure[Note.create(:E, 1+octave)]
      root_measure[Note.create(:G, 1+octave)]
      root_measure[Note.create(:F, 1+octave)]

      se.note(Note.create(:E, 1+octave), st: 480, gt: 480)
      se.note(Note.create(:E, 1+octave), st: 240, gt: 240)
      se.note(Note.create(:A, 1+octave), st: 240, gt: 240)
      se.note(Note.create(:A, 1+octave), st: 240, gt: 240)
      se.note(Note.create(:E, 1+octave), st: 240, gt: 240)
      se.note(Note.create(:E, 1+octave), st: 240, gt: 240)
      se.note(Note.create(:E, 1+octave), st: 240, gt: 240)

      se.note(Note.create(:A, 1+octave), st: 240, gt: 240)
      se.note(Note.create(:A, 1+octave), st: 240, gt: 240)
      se.note(Note.create(:E, 1+octave), st: 240, gt: 240)
      se.note(Note.create(:E, 1+octave), st: 480, gt: 240)
      se.note(Note.create(:E, 1+octave), st: 240, gt: 240)
      se.note(Note.create(:E, 1+octave), st: 240, gt: 240)
      se.note(Note.create(:E, 1+octave), st: 240, gt: 240)

      se.step(480)
      se.complete
    }

    AudioInputStepEditor.new(synth, se)
  end

  def create_snare
    op1 = Operator.new(
      source: OscillatorSource::Sine.instance,
      level: Decibel.dx7(99).mag,
      fixed_freq: nil,
      ratio_freq: 1.0,
      envelope: Modulation::Dx7Envelope.new(
        r1: 99, r2: 46, r3: 99, r4: 45,
        l1: 99, l2: 0,  l3: 0,  l4: 0
      ),
      phase: 0.0,
      pmd: 0.0,
      amd: 0.0,
    )

    op2 = Operator.new(
      source: OscillatorSource::Sine.instance,
      level: Decibel.dx7(99).mag,
      fixed_freq: nil,
      ratio_freq: 1.0,
      envelope: Modulation::Dx7Envelope.new(
        r1: 99, r2: 75, r3: 99, r4: 40,
        l1: 99, l2: 82, l3: 0,  l4: 0
      ),
      phase: 0.0,
      pmd: 0.0,
      amd: 0.0,
    )

    op3 = Operator.new(
      source: OscillatorSource::Sine.instance,
      level: Decibel.dx7(68).mag,
      fixed_freq: 1,
      ratio_freq: nil,
      envelope: Modulation::Dx7Envelope.new(
        r1: 88, r2: 53, r3: 99, r4: 50,
        l1: 99, l2: 0,  l3: 0,  l4: 0
      ),
      phase: 0.0,
      pmd: 0.0,
      amd: 0.0,
    )

    op4 = Operator.new(
      source: OscillatorSource::Sine.instance,
      level: Decibel.dx7(99).mag,
      fixed_freq: 10,
      ratio_freq: nil,
      envelope: Modulation::Dx7Envelope.new(
        r1: 99, r2: 53, r3: 90, r4: 45,
        l1: 99, l2: 0,  l3: 0,  l4: 0
      ),
      phase: 0.0,
      pmd: 0.0,
      amd: 0.0,
    )

    op5 = Operator.new(
      source: OscillatorSource::Sine.instance,
      level: Decibel.dx7(99).mag,
      fixed_freq: 100,
      ratio_freq: nil,
      envelope: Modulation::Dx7Envelope.new(
        r1: 99, r2: 51, r3: 90, r4: 15,
        l1: 99, l2: 99, l3: 99, l4: 0
      ),
      phase: 0.0,
      pmd: 0.0,
      amd: 0.0,
    )

    op6 = Operator.new(
      source: OscillatorSource::Sine.instance,
      level: Decibel.dx7(99).mag,
      fixed_freq: 6025.6,
      ratio_freq: nil,
      envelope: Modulation::Dx7Envelope.new(
        r1: 99, r2: 37, r3: 99, r4: 0,
        l1: 99, l2: 99, l3: 99, l4: 0
      ),
      phase: 0.0,
      pmd: 0.0,
      amd: 0.0,
    )

    synth = FmSynth.new(
      operators: {
        op1: op1,
        op2: op2,
        op3: op3,
        op4: op4,
        op5: op5,
        op6: op6,
      },
      algorithm: Algorithm.new
        .add(:op2, :op1)
        .add(:op3, :op1)
        .add(:op6, :op5, :op4, :op1),
      soundinfo: @soundinfo,
      quality: @quality,
    ).build


    se = StepEditor::StGt.new(bpm: @soundinfo.bpm) {|se|
      se.step(480)

      7.times {
        se.note(Note.create(:C, 2), st: 120, gt: 120)
        se.note(Note.create(:C, 2), st: 120, gt: 120)
        se.note(Note.create(:C, 2), st: 240, gt: 120)
        se.note(Note.create(:C, 2), st: 120, gt: 120)
        se.note(Note.create(:C, 2), st: 120, gt: 120)
        se.note(Note.create(:C, 2), st: 240, gt: 120)
        se.note(Note.create(:C, 2), st: 240, gt: 120)
        se.note(Note.create(:C, 2), st: 120, gt: 120)
        se.note(Note.create(:C, 2), st: 240, gt: 120)
        se.note(Note.create(:C, 2), st: 120, gt: 120)
        se.note(Note.create(:C, 2), st: 120, gt: 120)
        se.note(Note.create(:C, 2), st: 120, gt: 120)

        se.note(Note.create(:C, 2), st: 240, gt: 120)
        se.note(Note.create(:C, 2), st: 240, gt: 120)
        se.note(Note.create(:C, 2), st: 60, gt: 60, vel: 0.5)
        se.note(Note.create(:C, 2), st: 60, gt: 60, vel: 0.5)
        se.note(Note.create(:C, 2), st: 60, gt: 60, vel: 0.5)
        se.note(Note.create(:C, 2), st: 60, gt: 60, vel: 0.5)
        se.note(Note.create(:C, 2), st: 240, gt: 120)
        se.note(Note.create(:C, 2), st: 240, gt: 120)
        se.note(Note.create(:C, 2), st: 120, gt: 120)
        se.note(Note.create(:C, 2), st: 240, gt: 120)
        se.note(Note.create(:C, 2), st: 120, gt: 120)
        se.note(Note.create(:C, 2), st: 120, gt: 120)
        se.note(Note.create(:C, 2), st: 120, gt: 120)
      }

      se.note(Note.create(:C, 2), st: 120, gt: 120)
      se.note(Note.create(:C, 2), st: 120, gt: 120)
      se.note(Note.create(:C, 2), st: 1200, gt: 120)

      se.note(Note.create(:C, 2), st: 120, gt: 120)
      se.note(Note.create(:C, 2), st: 120, gt: 120)
      se.note(Note.create(:C, 2), st: 120, gt: 120)

      se.step(480)
      se.complete
    }

    AudioInputStepEditor.new(synth, se)
  end

  def create_timpani
    op1 = Operator.new(
      source: OscillatorSource::Sine.instance,
      level: Decibel.dx7(99).mag,
      fixed_freq: nil,
      ratio_freq: 0.5,
      envelope: Modulation::Dx7Envelope.new(
        r1: 99, r2: 36, r3: 98, r4: 39,
        l1: 99, l2: 0,  l3: 0,  l4: 0
      ),
      phase: 0.0,
      pmd: 0.0,
      amd: 0.0,
    )

    op2 = Operator.new(
      source: OscillatorSource::Sine.instance,
      level: Decibel.dx7(86).mag,
      fixed_freq: nil,
      ratio_freq: 0.5,
      envelope: Modulation::Dx7Envelope.new(
        r1: 99, r2: 74, r3: 0,  r4: 0,
        l1: 99, l2: 0,  l3: 0,  l4: 0
      ),
      phase: 0.0,
      pmd: 0.0,
      amd: 0.0,
    )

    op3 = Operator.new(
      source: OscillatorSource::Sine.instance,
      level: Decibel.dx7(85).mag,
      fixed_freq: nil,
      ratio_freq: 0.68,
      envelope: Modulation::Dx7Envelope.new(
        r1: 99, r2: 77, r3: 26, r4: 23,
        l1: 99, l2: 72,  l3: 0,  l4: 0
      ),
      phase: 0.0,
      pmd: 0.0,
      amd: 0.0,
    )

    op4 = Operator.new(
      source: OscillatorSource::Sine.instance,
      level: Decibel.dx7(87).mag,
      fixed_freq: nil,
      ratio_freq: 0.875,
      envelope: Modulation::Dx7Envelope.new(
        r1: 99, r2: 31, r3: 17, r4: 30,
        l1: 99, l2: 75, l3: 0,  l4: 0
      ),
      phase: 0.0,
      pmd: 0.0,
      amd: 0.0,
    )

    op5 = Operator.new(
      source: OscillatorSource::Sine.instance,
      level: Decibel.dx7(73).mag,
      fixed_freq: nil,
      ratio_freq: 0.5,
      envelope: Modulation::Dx7Envelope.new(
        r1: 99, r2: 50, r3: 26, r4: 19,
        l1: 99, l2: 0,  l3: 0,  l4: 0
      ),
      phase: 0.0,
      pmd: 0.0,
      amd: 0.0,
    )

    op6 = Operator.new(
      source: OscillatorSource::Sine.instance,
      level: Decibel.dx7(73).mag,
      fixed_freq: nil,
      ratio_freq: 0.78,
      envelope: Modulation::Dx7Envelope.new(
        r1: 99, r2: 2,  r3: 26, r4: 27,
        l1: 99, l2: 0,  l3: 0,  l4: 0
      ),
      phase: 0.0,
      pmd: 0.0,
      amd: 0.0,
    )

    synth = FmSynth.new(
      operators: {
        op1: op1,
        op2: op2,
        op3: op3,
        op4: op4,
        op5: op5,
        op6: op6,
      },
      algorithm: Algorithm.new
        .add(:op2, :op1)
        .add(:op4, :op3, :op1)
        .add(:op6, :op5, :op1),
      soundinfo: @soundinfo,
      quality: @quality,
    ).build


    se = StepEditor::StGt.new(bpm: @soundinfo.bpm) {|se|
      octave = 2
      se.step(480)

      root_measure = ->(note) {
        up_note = Note.new(note.num+12)
        se.note(up_note, st: 480, gt: 480)
        se.note(note, st: 240, gt: 240)
        se.note(up_note, st: 480, gt: 480)
        se.note(note, st: 240, gt: 240)
        se.note(note, st: 240, gt: 240)
        se.note(note, st: 240, gt: 240)
      }

      root_measure[Note.create(:A, 0+octave)]
      root_measure[Note.create(:A, 0+octave)]
      root_measure[Note.create(:"F#", 0+octave)]
      root_measure[Note.create(:"F#", 0+octave)]
      root_measure[Note.create(:A, 0+octave)]
      root_measure[Note.create(:A, 0+octave)]
      root_measure[Note.create(:"F#", 0+octave)]
      root_measure[Note.create(:"F#", 0+octave)]
      root_measure[Note.create(:F, 0+octave)]
      root_measure[Note.create(:F, 0+octave)]
      root_measure[Note.create(:E, 0+octave)]
      root_measure[Note.create(:E, 0+octave)]
      root_measure[Note.create(:G, 0+octave)]
      root_measure[Note.create(:F, 0+octave)]

      se.step(720)
      se.note(Note.create(:F, 1+octave), st: 120, gt: 120)
      se.note(Note.create(:F, 1+octave), st: 120, gt: 120)
      se.note(Note.create(:F, 1+octave), st: 480, gt: 480)


      se.step(480)
      se.complete
    }

    AudioInputStepEditor.new(synth, se)
  end

  def create_piccolo
    op1 = Operator.new(
      source: OscillatorSource::Sine.instance,
      level: Decibel.dx7(99).mag,
      fixed_freq: nil,
      ratio_freq: 3.96,
      envelope: Modulation::Dx7Envelope.new(
        r1: 39, r2: 62, r3: 52, r4: 63,
        l1: 99, l2: 98, l3: 97, l4: 0
      ),
      phase: 0.0,
      pmd: 0.0,
      amd: 0.0,
    )

    op2 = Operator.new(
      source: OscillatorSource::Sine.instance,
      level: Decibel.dx7(75).mag,
      fixed_freq: nil,
      ratio_freq: 4.0,
      envelope: Modulation::Dx7Envelope.new(
        r1: 79, r2: 60, r3: 57, r4: 33,
        l1: 63, l2: 99, l3: 99, l4: 0
      ),
      phase: 0.0,
      pmd: 0.0,
      amd: 0.0,
    )

    op3 = Operator.new(
      source: OscillatorSource::Sine.instance,
      level: Decibel.dx7(99).mag,
      fixed_freq: nil,
      ratio_freq: 4,
      envelope: Modulation::Dx7Envelope.new(
        r1: 61, r2: 62, r3: 52, r4: 63,
        l1: 99, l2: 98, l3: 97, l4: 0
      ),
      phase: 0.0,
      pmd: 0.0,
      amd: 0.0,
    )

    op4 = Operator.new(
      source: OscillatorSource::Sine.instance,
      level: Decibel.dx7(67).mag,
      fixed_freq: nil,
      ratio_freq: 4.0,
      envelope: Modulation::Dx7Envelope.new(
        r1: 59, r2: 60, r3: 57, r4: 33,
        l1: 63, l2: 99, l3: 99, l4: 0
      ),
      phase: 0.0,
      pmd: 0.0,
      amd: 0.0,
    )

    op5 = Operator.new(
      source: OscillatorSource::Sine.instance,
      level: Decibel.dx7(99).mag,
      fixed_freq: nil,
      ratio_freq: 3.99,
      envelope: Modulation::Dx7Envelope.new(
        r1: 55, r2: 62, r3: 52, r4: 63,
        l1: 99, l2: 98, l3: 97, l4: 0
      ),
      phase: 0.0,
      pmd: 0.0,
      amd: 0.0,
    )

    op6 = Operator.new(
      source: OscillatorSource::Sine.instance,
      level: Decibel.dx7(57).mag,
      fixed_freq: nil,
      ratio_freq: 8.0,
      envelope: Modulation::Dx7Envelope.new(
        r1: 79, r2: 60, r3: 57, r4: 33,
        l1: 63, l2: 99, l3: 99, l4: 0
      ),
      phase: 0.0,
      pmd: 0.0,
      amd: 0.0,
    )

    synth = FmSynth.new(
      operators: {
        op1: op1,
        op2: op2,
        op3: op3,
        op4: op4,
        op5: op5,
        op6: op6,
      },
      algorithm: Algorithm.new
        .add(:op2, :op1)
        .add(:op4, :op3)
        .add(:op6, :op5),
      soundinfo: @soundinfo,
      quality: @quality,
    ).build


    se = StepEditor::StGt.new(bpm: @soundinfo.bpm) {|se|
      octave = 1
      se.step(480)

      se.step(480*4*15)

      se.note(Note.create(:E, 1+octave), st: 60, gt: 60)
      se.note(Note.create(:"F#", 1+octave), st: 60, gt: 60)
      se.note(Note.create(:G, 1+octave), st: 60, gt: 60)
      se.note(Note.create(:A, 1+octave), st: 60, gt: 60)
      se.note(Note.create(:B, 1+octave), st: 60, gt: 60)
      se.note(Note.create(:D, 2+octave), st: 60, gt: 60)
      se.note(Note.create(:E, 2+octave), st: 60, gt: 60)
      se.note(Note.create(:"F#", 2+octave), st: 60, gt: 60)

      se.note(Note.create(:A, 1+octave), st: 60, gt: 60)
      se.note(Note.create(:B, 1+octave), st: 60, gt: 60)
      se.note(Note.create(:D, 2+octave), st: 60, gt: 60)
      se.note(Note.create(:E, 2+octave), st: 60, gt: 60)
      se.note(Note.create(:"F#", 2+octave), st: 60, gt: 60)
      se.note(Note.create(:G, 2+octave), st: 60, gt: 60)
      se.note(Note.create(:A, 2+octave), st: 60, gt: 60)
      se.note(Note.create(:B, 2+octave), st: 60, gt: 60)

      se.note(Note.create(:D, 2+octave), st: 60, gt: 60)
      se.note(Note.create(:E, 2+octave), st: 60, gt: 60)
      se.note(Note.create(:"F#", 2+octave), st: 60, gt: 60)
      se.note(Note.create(:G, 2+octave), st: 60, gt: 60)
      se.note(Note.create(:A, 2+octave), st: 60, gt: 60)
      se.note(Note.create(:B, 2+octave), st: 60, gt: 60)
      se.note(Note.create(:D, 3+octave), st: 60, gt: 60)
      se.note(Note.create(:E, 3+octave), st: 60, gt: 60)

      se.note(Note.create(:"F#", 2+octave), st: 60, gt: 60)
      se.note(Note.create(:G, 2+octave), st: 60, gt: 60)
      se.note(Note.create(:A, 2+octave), st: 60, gt: 60)
      se.note(Note.create(:B, 2+octave), st: 60, gt: 60)
      se.note(Note.create(:D, 3+octave), st: 60, gt: 60)
      se.note(Note.create(:E, 3+octave), st: 60, gt: 60)
      se.note(Note.create(:G, 3+octave), st: 60, gt: 60)
      se.note(Note.create(:A, 3+octave), st: 60, gt: 60)

      se.step(480*2)
      se.complete
    }

    AudioInputStepEditor.new(synth, se)
  end


  def mixer
    bus1 = AudioBus.new

    @inputs[:oboe]
      .send_to(bus1, gain: -6)

    @inputs[:string]
      .send_to(bus1, gain: -15, pan: -0.4)

    @inputs[:bass]
      .send_to(bus1, gain: -6)

    @inputs[:snare]
      .send_to(bus1, gain: -6, pan: 0.4)

    @inputs[:timpani]
      .send_to(bus1, gain: -15)

    @inputs[:piccolo]
      .send_to(bus1, gain: -20)

    bus1
      .fx(Compressor.new(threshold: 0.5, ratio: 0.8))
      .send_to(@output, gain: -8)


    conductor = Conductor.new(
      input: @inputs.values,
      output: @output
    )
    conductor.connect
    conductor.join
  end
end

ChronoTrigger.new.mixer
