class BufferPlayer
  def initialize(soundinfo, id=nil, level: 0.0)
    id ||= "tmp_#{Time.now.to_f.to_s.sub('.', '_')}"
    @path = "output_#{id}.wav"
    @sound = RubyAudio::Sound.open(@path, "w", soundinfo)
    @a_gain = AudioStream::Fx::AGain.new(level: level)
  end

  def write(buffers)
    [buffers].flatten.compact.each {|buffer|
      buffer = @a_gain.process(buffer)
      @sound.write(buffer.to_rabuffer)
    }
  end

  def close
    @sound.close
  end

  def display
    tag = "<audio controls src='#{@path}'></audio>"
    IRuby.display tag, mime: 'text/html'
  end

  def self.play(soundinfo, id=nil, level: 0.0, margin: 0.1)
    margin = AudioStream::Rate.sec(margin)
    empty = AudioStream::Buffer.create(soundinfo.window_size, soundinfo.channels)

    player = self.new(soundinfo, id, level: level)

    margin.frame(soundinfo).ceil.times {
      player.write(empty)
    }

    yield player

    margin.frame(soundinfo).ceil.times {
      player.write(empty)
    }

    player.close
    player.display
  end
end
