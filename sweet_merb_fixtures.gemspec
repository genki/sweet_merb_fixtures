# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{sweet_merb_fixtures}
  s.version = "0.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Yukiko Kawamoto"]
  s.date = %q{2009-02-18}
  s.description = %q{Merb plugin that provides the system to create records from YAML files.}
  s.email = %q{yu0420@gmail.com}
  s.extra_rdoc_files = ["README", "LICENSE", "TODO"]
  s.files = ["LICENSE", "README", "Rakefile", "TODO", "lib/sweet_merb_fixtures.rb", "lib/sweet_merb_fixtures", "lib/sweet_merb_fixtures/merbtasks.rb", "lib/sweet_merb_fixtures/dm_associations.rb", "lib/sweet_merb_fixtures/merb_fixtures.rb", "lib/sweet_merb_fixtures/merb_fixtures", "lib/sweet_merb_fixtures/merb_fixtures/hash.rb", "spec/sweet_merb_fixtures_spec.rb", "spec/spec_helper.rb", "spec/fixture", "spec/fixture/app", "spec/fixture/app/models", "spec/fixture/app/models/parent.rb", "spec/fixture/app/models/tagging.rb", "spec/fixture/app/models/tag.rb", "spec/fixture/app/models/child.rb", "spec/fixture/app/models/grand_child.rb", "spec/fixture/lib", "spec/fixture/lib/fixtures", "spec/fixture/lib/fixtures/gc.yml", "spec/fixture/lib/fixtures/chain.yml"]
  s.has_rdoc = true
  s.homepage = %q{github.com/yukiko}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{merb}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Merb plugin that provides the system to create records from YAML files.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<merb>, [">= 1.0.9"])
      s.add_runtime_dependency(%q<dm-core>, [">= 0.9.10"])
    else
      s.add_dependency(%q<merb>, [">= 1.0.9"])
      s.add_dependency(%q<dm-core>, [">= 0.9.10"])
    end
  else
    s.add_dependency(%q<merb>, [">= 1.0.9"])
    s.add_dependency(%q<dm-core>, [">= 0.9.10"])
  end
end
