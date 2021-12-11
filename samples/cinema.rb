$LOAD_PATH << File.dirname(__FILE__) + "/../lib"
$LOAD_PATH << File.dirname(__FILE__) + "/../../ruby-audio_stream/lib"

require 'synthesizer'
require 'audio_stream'

include AudioStream
include AudioStream::Fx
include Synthesizer


class Cinema
  def initialize
    @soundinfo = SoundInfo.new(
      channels: 2,
      samplerate: 44100,
      window_size: 1024,
      format: RubyAudio::FORMAT_WAV|RubyAudio::FORMAT_PCM_16,
      bpm: 145.0
    )

    @default_amp = Amplifier.new(
      volume: ModulationValue.new(1.0)
        .add(Modulation::Adsr.new(
          attack: Rate.sec(0.05),
          hold: Rate.sec(0.1),
          decay: Rate.sec(0.4),
          sustain: 0.8,
          release: Rate.sec(0.0)
        ), depth: 1.0),
    )

    @inputs = {
      dub4: create_dub4,
      dub8: create_dub8,
      dub16: create_dub16,
      dub2: create_dub2,
      dub4_down: create_dub4_down,
      dub_tremoro: create_dub_tremoro,
      vocoder: create_vocoder,
      bass: create_bass,
      drum: AudioInput.file(File.dirname(__FILE__)+"/cinema_drum.wav", soundinfo: @soundinfo)
    }

    #@output = AudioOutput.device(soundinfo: @soundinfo)
    @output = AudioOutput.file(File.dirname(__FILE__)+"/output_cinema.wav", soundinfo: @soundinfo)
  end

  def create_dub4
    lfo1 = Modulation::Lfo.new(
      shape: Shape::Sine,
      delay: Rate.sec(0.0),
      attack: Rate.sec(0.0),
      attack_curve: Modulation::Curve::EaseIn,
      phase: 0.0,
      rate: Rate::SYNC_1_4
    )

    synth = PolySynth.new(
      oscillators: [
        Oscillator.new(
          source: OscillatorSource::SawtoothSquare.instance,
          volume: ModulationValue.new(1.0)
            .add(lfo1, depth: 0.1),
          sync: ModulationValue.new(12+6.0)
            .add(lfo1, depth: 6.0),
          uni_num: 4,
          uni_detune: 0.03,
          uni_stereo: 1.0,
        ),
        Oscillator.new(
          source: OscillatorSource::FormantVocoder.new(
            vowels: [:u, :a],
            pronunciation: ModulationValue.new(0.0)
              .add(lfo1, depth: 1.0),
          ),
          volume: ModulationValue.new(1.0)
            .add(lfo1, depth: 0.1),
          sync: ModulationValue.new(6.0)
            .add(lfo1, depth: 6.0),
          uni_num: 4,
          uni_detune: 0.03,
          uni_stereo: -1.0,
        ),
      ],
      filter: Filter::Serial.new(
        Filter::BandPassFilter.new(freq: 1000, bandwidth: 4.0),
        Filter::PeakingFilter.new(
          freq: ModulationValue.new(20000)
            .add(lfo1, depth: 19500),
          bandwidth: 4.0,
          gain: 10),
      ),
      amplifier: @default_amp,
      quality: Quality::HIGH,
      soundinfo: @soundinfo,
    )

    se = StepEditor::StGt.new(bpm: @soundinfo.bpm) {|se|
      se.step(480*4)

      se.note(Note.create(:"F#", 1), gt: 360)
      se.note(Note.create(:A, 2), st: 480, gt: 360)
      se.note(Note.create(:"F#", 1), gt: 360)
      se.note(Note.create(:"F#", 2), st: 480, gt: 360)
      se.step(480*2)
      se.step(480*4)

      se.note(Note.create(:"F#", 1), gt: 360)
      se.note(Note.create(:A, 2), st: 480, gt: 360)
      se.note(Note.create(:"F#", 1), gt: 360)
      se.note(Note.create(:"F#", 2), st: 480, gt: 360)
      se.step(480*2)
      se.step(480*3)

      se.note(Note.create(:"F#", 1), gt: 240)
      se.note(Note.create(:E, 2), st: 240, gt: 240)
      se.note(Note.create(:"F#", 1), gt: 240)
      se.note(Note.create(:"F#", 2), st: 240, gt: 240)

      se.note(Note.create(:"F#", 1), gt: 360)
      se.note(Note.create(:A, 2), st: 480, gt: 360)
      se.note(Note.create(:"F#", 1), gt: 360)
      se.note(Note.create(:"F#", 2), st: 480, gt: 360)
      se.step(480*2)
      se.step(480*4)


      se.complete
    }

    AudioInputStepEditor.new(synth, se)
  end

  def create_dub8
    lfo1 = Modulation::Lfo.new(
      shape: Shape::Sine,
      delay: Rate.sec(0.0),
      attack: Rate.sec(0.0),
      attack_curve: Modulation::Curve::EaseIn,
      phase: 0.0,
      rate: Rate::SYNC_1_8
    )

    synth = PolySynth.new(
      oscillators: [
        Oscillator.new(
          source: OscillatorSource::SawtoothSquare.instance,
          volume: ModulationValue.new(1.0)
            .add(lfo1, depth: 1.0),
          sync: ModulationValue.new(12+6.0)
            .add(lfo1, depth: 6.0),
          uni_num: 4,
          uni_detune: 0.03,
          uni_stereo: 1.0,
        ),
        Oscillator.new(
          source: OscillatorSource::FormantVocoder.new(
            vowels: [:u, :a],
            pronunciation: ModulationValue.new(0.0)
              .add(lfo1, depth: 1.0),
          ),
          volume: ModulationValue.new(1.0)
            .add(lfo1, depth: 1.0),
          tune_semis: 0,
          sync: ModulationValue.new(6.0)
            .add(lfo1, depth: 6.0),
          uni_num: 4,
          uni_detune: 0.03,
          uni_stereo: 1.0,
        ),
        Oscillator.new(
          source: OscillatorSource::FormantVocoder.new(
            vowels: [:u, :a],
            pronunciation: ModulationValue.new(0.0)
              .add(lfo1, depth: 1.0),
          ),
          volume: ModulationValue.new(1.0)
            .add(lfo1, depth: 1.0),
          tune_semis: -12,
          sync: ModulationValue.new(12+6.0)
            .add(lfo1, depth: 6.0),
          uni_num: 4,
          uni_detune: 0.03,
          uni_stereo: -1.0,
        ),
      ],
      filter: Filter::Serial.new(
        Filter::BandPassFilter.new(freq: 3000, bandwidth: 4.0),
        Filter::PeakingFilter.new(
          freq: ModulationValue.new(20000)
            .add(lfo1, depth: 19500),
          bandwidth: 2.0,
          gain: 10),
      ),
      amplifier: @default_amp,
      quality: Quality::HIGH,
      soundinfo: @soundinfo,
    )

    se = StepEditor::StGt.new(bpm: @soundinfo.bpm) {|se|
      se.step(480*4)

      se.step(480*2)
      se.note(Note.create(:"F#", 4), st: 480*4, gt: 480*4)
      se.step(480*2)

      se.step(480*4)
      se.step(480*4)

      se.step(480*2)
      se.note(Note.create(:"F#", 4), st: 480*4, gt: 480*4)
      se.step(480*2)

      se.complete
    }

    AudioInputStepEditor.new(synth, se)
  end

  def create_dub16
    lfo1 = Modulation::Lfo.new(
      shape: Shape::Sine,
      delay: Rate.sec(0.0),
      attack: Rate.sec(0.0),
      attack_curve: Modulation::Curve::EaseIn,
      phase: 0.0,
      rate: Rate::SYNC_1_16
    )

    synth = PolySynth.new(
      oscillators: [
        Oscillator.new(
          source: OscillatorSource::SawtoothSquare.instance,
          volume: ModulationValue.new(1.0)
            .add(lfo1, depth: 1.0),
          sync: ModulationValue.new(12+6.0)
            .add(lfo1, depth: 6.0),
          uni_num: 4,
          uni_detune: 0.03,
          uni_stereo: 0.6,
        ),
        Oscillator.new(
          source: OscillatorSource::FormantVocoder.new(
            vowels: [:u, :a],
            pronunciation: ModulationValue.new(0.0)
              .add(lfo1, depth: 1.0),
          ),
          volume: ModulationValue.new(1.0)
            .add(lfo1, depth: 1.0),
          tune_semis: 0,
          sync: ModulationValue.new(12+6.0)
            .add(lfo1, depth: 6.0),
          uni_num: 4,
          uni_detune: 0.03,
          uni_stereo: 0.6,
        ),
        Oscillator.new(
          source: OscillatorSource::FormantVocoder.new(
            vowels: [:u, :a],
            pronunciation: ModulationValue.new(0.0)
              .add(lfo1, depth: 1.0),
          ),
          volume: ModulationValue.new(1.0)
            .add(lfo1, depth: 1.0),
          tune_semis: -12,
          sync: ModulationValue.new(12+6.0)
            .add(lfo1, depth: 6.0),
          uni_num: 4,
          uni_detune: 0.03,
          uni_stereo: 0.6,
        ),
      ],
      filter: Filter::Serial.new(
        Filter::BandPassFilter.new(freq: 3000, bandwidth: 4.0),
        Filter::PeakingFilter.new(
          freq: ModulationValue.new(20000)
            .add(lfo1, depth: 19500),
          bandwidth: 4.0,
          gain: 10),
      ),
      amplifier: @default_amp,
      quality: Quality::HIGH,
      soundinfo: @soundinfo,
    )

    se = StepEditor::StGt.new(bpm: @soundinfo.bpm) {|se|
      se.step(480*4)

      se.step(480*4)
      se.step(480*4)

      se.step(480*2)
      se.note(Note.create(:"F#", 4), st: 480*4, gt: 480*4)
      se.step(480*2)

      se.complete
    }

    AudioInputStepEditor.new(synth, se)
  end

  def create_dub2
    adsr1 = Modulation::Adsr.new(
      attack: Rate.sec(0.0),
      hold: Rate::SYNC_1_16,
      decay: Rate::SYNC_1_4D,
      #sustain_curve: Modulation::Curve::EaseOut,
      sustain_curve: Modulation::Curve::EaseIn,
      sustain: 0.0,
      release: Rate.sec(0.0)
    )

    synth = PolySynth.new(
      oscillators: [
        Oscillator.new(
          source: OscillatorSource::SawtoothSquare.instance,
          #volume: ModulationValue.new(1.0)
          #  .add(lfo1, depth: 1.0),
          tune_semis: ModulationValue.new(0.0)
            .add(adsr1, depth: 1.0),
          sync: ModulationValue.new(6.0)
            .add(adsr1, depth: 6.0),
        ),
        Oscillator.new(
          source: OscillatorSource::FormantVocoder.new(
            vowels: [:u, :a],
            pronunciation: ModulationValue.new(0.0)
              .add(adsr1, depth: 1.0),
          ),
          #volume: ModulationValue.new(1.0)
          #  .add(lfo1, depth: 1.0),
          tune_semis: ModulationValue.new(0.0)
            .add(adsr1, depth: 1.0),
          sync: ModulationValue.new(12+6.0)
            .add(adsr1, depth: 6.0),
        ),
      ],
      filter: Filter::Serial.new(
        #Filter::BandPassFilter.new(freq: 1000, bandwidth: 4.0),
        Filter::PeakingFilter.new(
          freq: ModulationValue.new(20000)
            .add(adsr1, depth: 19500),
          bandwidth: 4.0,
          gain: 10),
      ),
      amplifier: @default_amp,
      quality: Quality::HIGH,
      soundinfo: @soundinfo,
    )

    se = StepEditor::StGt.new(bpm: @soundinfo.bpm) {|se|
      se.step(480*4)

      se.step(480*4)
      se.step(480*2)
      se.note(Note.create(:"F#", 1), gt: 480*2)
      se.note(Note.create(:"F#", 2), st: 480*2, gt: 480*2)

      se.step(480*4)
      se.step(480*4)

      se.step(480*4)
      se.step(480*2)
      se.note(Note.create(:"F#", 1), gt: 480*2)
      se.note(Note.create(:"F#", 2), st: 480*2, gt: 480*2)

      se.complete
    }

    AudioInputStepEditor.new(synth, se)
  end

  def create_dub4_down
    lfo1 = Modulation::Lfo.new(
      shape: Shape::Sine,
      delay: Rate.sec(0.0),
      attack: Rate.sec(0.0),
      attack_curve: Modulation::Curve::EaseIn,
      phase: 0.0,
      rate: Rate::SYNC_1_128
    )
    adsr1 = Modulation::Adsr.new(
      attack: Rate.sec(0.0),
      hold: Rate::SYNC_1_16,
      decay: Rate::SYNC_1_4,
      sustain_curve: Modulation::Curve::Straight,
      sustain: 0.0,
      release: Rate.sec(0.0)
    )

    synth = PolySynth.new(
      oscillators: [
        Oscillator.new(
          source: OscillatorSource::SawtoothSquare.instance,
          volume: ModulationValue.new(1.0)
            .add(lfo1, depth: 1.0),
          tune_semis: ModulationValue.new(-8.0)
            .add(adsr1, depth: 8.0),
          #sync: ModulationValue.new(6.0)
          #  .add(adsr1, depth: 6.0),
        ),
        Oscillator.new(
          source: OscillatorSource::FormantVocoder.new(
            vowels: [:u, :a],
            pronunciation: ModulationValue.new(0.0)
              .add(adsr1, depth: 1.0),
          ),
          volume: ModulationValue.new(1.0)
            .add(lfo1, depth: 1.0),
          tune_semis: ModulationValue.new(-8.0)
            .add(adsr1, depth: 8.0),
          #sync: ModulationValue.new(12+6.0)
          #  .add(adsr1, depth: 6.0),
        ),
      ],
      filter: Filter::Serial.new(
        #Filter::BandPassFilter.new(freq: 1000, bandwidth: 4.0),
        Filter::PeakingFilter.new(
          freq: ModulationValue.new(20000)
            .add(adsr1, depth: 19500),
          bandwidth: 4.0,
          gain: 10),
      ),
      amplifier: @default_amp,
      quality: Quality::HIGH,
      soundinfo: @soundinfo,
    )

    se = StepEditor::StGt.new(bpm: @soundinfo.bpm) {|se|
      se.step(480*4)

      se.step(480*4)
      se.step(480*4)
      se.step(480*4)

      se.step(480*2)
      #se.note(Note.create(:G, 4), gt: 480)
      se.note(Note.create(:G, 6), st: 480, gt: 480)
      se.step(480)

      se.complete
    }

    AudioInputStepEditor.new(synth, se)
  end

  def create_dub_tremoro
    lfo1 = Modulation::Lfo.new(
      shape: Shape::Sine,
      delay: Rate.sec(0.0),
      attack: Rate.sec(0.0),
      attack_curve: Modulation::Curve::EaseIn,
      phase: 0.0,
      rate: Rate::SYNC_1_128
    )
    adsr1 = Modulation::Adsr.new(
      attack: Rate.sec(0.0),
      hold: Rate::SYNC_1_16,
      decay: Rate::SYNC_1_4,
      sustain_curve: Modulation::Curve::Straight,
      sustain: 0.0,
      release: Rate.sec(0.0)
    )

    synth = PolySynth.new(
      oscillators: [
        Oscillator.new(
          source: OscillatorSource::SawtoothSquare.instance,
          volume: ModulationValue.new(1.0)
            .add(lfo1, depth: 1.0),
          sync: 12,
        ),
        Oscillator.new(
          source: OscillatorSource::SawtoothSquare.instance,
          volume: ModulationValue.new(1.0)
            .add(lfo1, depth: 1.0),
          tune_semis: -12,
          sync: 12,
        ),
        Oscillator.new(
          source: OscillatorSource::FormantVocoder.new(
            vowels: [:u, :a],
            pronunciation: ModulationValue.new(0.0)
              .add(adsr1, depth: 1.0),
          ),
          volume: ModulationValue.new(1.0)
            .add(lfo1, depth: 1.0),
          #sync: ModulationValue.new(12+6.0)
          #  .add(adsr1, depth: 6.0),
        ),
      ],
      filter: Filter::Serial.new(
        #Filter::BandPassFilter.new(freq: 1000, bandwidth: 4.0),
        Filter::PeakingFilter.new(
          freq: ModulationValue.new(20000)
            .add(adsr1, depth: 19500),
          bandwidth: 4.0,
          gain: 10),
      ),
      amplifier: @default_amp,
      quality: Quality::HIGH,
      soundinfo: @soundinfo,
    )

    se = StepEditor::StGt.new(bpm: @soundinfo.bpm) {|se|
      se.step(480*4)

      se.step(480*4)
      se.step(480*4)
      se.step(480*4)
      se.step(480*4)
      se.step(480*4)
      se.step(480*4)

      se.note(Note.create(:"F#", 5), st: 480, gt: 480)
      se.step(480)
      se.note(Note.create(:"F#", 5), st: 480, gt: 480)
      se.step(480)

      se.note(Note.create(:A, 4), st: 480, gt: 480)
      se.note(Note.create(:"C#", 5), st: 480, gt: 480)
      se.note(Note.create(:A, 5), st: 480, gt: 480)
      se.note(Note.create(:"C#", 6), st: 480, gt: 480)

      se.complete
    }

    AudioInputStepEditor.new(synth, se)
  end

  def create_vocoder
    lfo1 = Modulation::Lfo.new(
      #shape: Shape::Square,
      shape: Shape::Sine,
      delay: Rate.sec(0.0),
      attack: Rate.sec(0.0),
      attack_curve: Modulation::Curve::EaseIn,
      phase: 0.0,
      rate: Rate::SYNC_1_8
    )

    synth = PolySynth.new(
      oscillators: [
        Oscillator.new(
          source: OscillatorSource::FormantVocoder.new(
            vowels: [:a, :i],
            pronunciation: ModulationValue.new(0.5)
              .add(lfo1, depth: -0.5),
          ),
          uni_num: 4,
          uni_detune: 0.1,
          uni_stereo: 0.4,
        ),
        Oscillator.new(
          source: OscillatorSource::FormantVocoder.new(
            vowels: [:a, :i],
            pronunciation: ModulationValue.new(0.5)
              .add(lfo1, depth: -0.5),
          ),
          tune_semis: -12,
          uni_num: 4,
          uni_detune: 0.1,
          uni_stereo: -0.4,
        ),
      ],
      filter: Filter::Serial.new(
        Filter::BandPassFilter.new(freq: 600, bandwidth: 3.0),
        Filter::PeakingFilter.new(freq: 400, bandwidth: 2.0, gain: 10),
      ),
      amplifier: @default_amp,
      quality: Quality::HIGH,
      soundinfo: @soundinfo,
    )

    se = StepEditor::StGt.new(bpm: @soundinfo.bpm) {|se|
      se.step(480*4)

      se.step(480*4)
      se.step(480*4)
      se.step(480*4)
      se.step(480*4)
      se.step(480*4)
      se.step(480*4)

      se.step(480)
      se.note(Note.create(:"F#", 2), st: 480, gt: 480)
      se.step(480)
      se.note(Note.create(:"F#", 2), st: 480, gt: 480)

      se.complete
    }

    AudioInputStepEditor.new(synth, se)
  end

  def create_bass
    lfo1 = Modulation::Lfo.new(
      shape: Shape::Sine,
      delay: Rate.sec(0.0),
      attack: Rate.sec(0.0),
      attack_curve: Modulation::Curve::EaseIn,
      phase: 0.0,
      rate: Rate::SYNC_1_4
    )
    lfo2 = Modulation::Lfo.new(
      shape: Shape::Sine,
      delay: Rate.sec(0.0),
      attack: Rate.sec(0.0),
      attack_curve: Modulation::Curve::EaseIn,
      phase: 0.0,
      rate: Rate::SYNC_1_128
    )

    synth = PolySynth.new(
      oscillators: [
        Oscillator.new(
          source: OscillatorSource::SawtoothSquare.instance,
          volume: ModulationValue.new(1.0)
            .add(lfo1, depth: 0.7)
            .add(lfo2, depth: 0.5),
          sync: 12,
        ),
      ],
      filter: Filter::Serial.new(
        Filter::LowPassFilter.new(freq: 200, q: Filter::DEFAULT_Q),
      ),
      amplifier: @default_amp,
      soundinfo: @soundinfo,
    )

    se = StepEditor::StGt.new(bpm: @soundinfo.bpm) {|se|
      se.step(480*4)

      se.note(Note.create(:A, 1), st: 480, gt: 480)
      se.note(Note.create(:"F#", 1), st: 480*5, gt: 480*5)
      se.note(Note.create(:G, 1), st: 480*2, gt: 480*2)

      se.note(Note.create(:A, 1), st: 480, gt: 480)
      se.note(Note.create(:"F#", 1), st: 480*6, gt: 480*6)
      se.note(Note.create(:E, 1), st: 240, gt: 240)
      se.note(Note.create(:"F#", 1), st: 240, gt: 240)

      se.note(Note.create(:A, 1), st: 480, gt: 480)
      se.note(Note.create(:"F#", 1), st: 480*5, gt: 480*5)
      se.note(Note.create(:G, 1), st: 480*2, gt: 480*2)

      se.note(Note.create(:"F#", 1), st: 480*2, gt: 480*2)
      se.note(Note.create(:"F#", 1), st: 480*2, gt: 480*2)

      se.note(Note.create(:A, 1), st: 480, gt: 480)
      se.note(Note.create(:"C#", 2), st: 480, gt: 480)
      se.note(Note.create(:A, 2), st: 480, gt: 480)
      se.note(Note.create(:"C#", 3), st: 480, gt: 480)

      se.complete
    }

    AudioInputStepEditor.new(synth, se)
  end

  def mixer
    low_bus = AudioBus.new
    high_bus = AudioBus.new
    master = AudioBus.new

    @inputs[:dub4]
      .send_to(low_bus, gain: 0.0, pan: 0.0)

    @inputs[:dub8]
      .send_to(high_bus, gain: 0.0, pan: 0.0)

    @inputs[:dub16]
      .send_to(high_bus, gain: 0.0, pan: 0.0)

    @inputs[:dub2]
      .send_to(low_bus, gain: -9.0, pan: 0.0)

    @inputs[:dub4_down]
      .send_to(high_bus, gain: -5.0, pan: 0.0)

    @inputs[:dub_tremoro]
      .send_to(high_bus, gain: -9.0, pan: 0.0)

    @inputs[:vocoder]
      .fx(Compressor.new(threshold: 0.5, ratio: 0.8))
      .send_to(master, gain: -14.0, pan: 0.0)

    @inputs[:bass]
      .send_to(master, gain: -30.0, pan: 0.0)

    low_bus
      .fx(AGain.new(level: -30.0))
      .fx(Compressor.new(threshold: 0.5, ratio: 0.8))
      .send_to(master, gain: -2.0)
      .fx(HighPassFilter.create(@soundinfo, freq: 200, q: 0.2))
      .fx(SchroederReverb.new(@soundinfo, dry: -100.0, wet: -10.0))
      .send_to(master, gain: 0.0)
      .fx(SchroederReverb.new(@soundinfo, dry: -100.0, wet: -10.0))
      .send_to(master, gain: 0.0)

    high_bus
      .fx(AGain.new(level: -30.0))
      .fx(HighShelfFilter.create(@soundinfo, freq: 1700.0, q: 0.5, gain: 0.5))
      .fx(PeakingFilter.create(@soundinfo, freq: 2200, bandwidth: 2.0, gain: 5))
      .fx(Compressor.new(threshold: 0.5, ratio: 0.8))
      .send_to(master, gain: -6.0)
      .fx(HighPassFilter.create(@soundinfo, freq: 800, q: 0.2))
      .fx(SchroederReverb.new(@soundinfo, dry: -100.0, wet: -10.0))
      .send_to(master, gain: -2.0)

    @inputs[:drum]
      .send_to(master, gain: -1.0)

    master
      .fx(Compressor.new(threshold: 0.5, ratio: 0.8))
      .send_to(@output)


    conductor = Conductor.new(
      input: @inputs.values,
      output: @output
    )
    conductor.connect
    conductor.join
  end
end


Cinema.new.mixer
