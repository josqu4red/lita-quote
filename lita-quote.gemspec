Gem::Specification.new do |spec|
  spec.name          = "lita-quote"
  spec.version       = "0.1.1"
  spec.authors       = ["Jonathan Amiez"]
  spec.email         = ["jonathan.amiez@gmail.com"]
  spec.description   = "Quote handler for Lita"
  spec.summary       = "Store quotes added by users and display them back"
  spec.homepage      = "https://github.com/josqu4red/lita-quote"
  spec.license       = "MIT"
  spec.metadata      = { "lita_plugin_type" => "handler" }

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "lita", "~> 4.0"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", ">= 3.0.0.beta2"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "coveralls"
end
