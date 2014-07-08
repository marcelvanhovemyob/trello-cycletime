Gem::Specification.new do |spec|
  spec.name        = 'TrelloCycleTime'
  spec.version     = '1.0.3'
  spec.summary     = "Calculates cycle time from cards on a trello board"
  spec.authors     = ["iainjmitchell"]
  spec.email       = 'iainjmitchell@gmail.com'
  spec.files       = Dir.glob("lib/*")
  spec.homepage    = 'https://github.com/code-computerlove/trello-cycletime'
  spec.license       = 'MIT'
  spec.add_runtime_dependency 'ruby-trello' 
  spec.add_runtime_dependency 'peach' 
end