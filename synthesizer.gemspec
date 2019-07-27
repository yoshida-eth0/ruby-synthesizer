lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "synthesizer/version"

Gem::Specification.new do |spec|
  spec.name          = "synthesizer"
  spec.version       = Synthesizer::VERSION
  spec.authors       = ["Yoshida Tetsuya"]
  spec.email         = ["yoshida.eth0@gmail.com"]

  spec.summary       = %q{Synthesizer implemented in Ruby.}
  spec.description   = %q{Synthesizer implemented in Ruby.}
  spec.homepage      = "https://github.com/yoshida-eth0/ruby-synthesizer"
  spec.license       = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "minitest", "~> 5.0"

  spec.add_dependency "audio_stream", ">= 1.3.0"
end
