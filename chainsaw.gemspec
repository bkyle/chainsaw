require 'rake'

Gem::Specification.new do |s|
    s.name = 'chainsaw'
    s.version = '0.1.0'
    s.date = '2013-01-07'
    s.summary = 'Command line tool to interact with XML documents'
    s.files = FileList['lib/**/*.rb']
    s.executables << "chainsaw"
end