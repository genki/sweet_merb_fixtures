Merb.logger.info "load merb_fixtures." #<TODO delete this line later
Merb.push_path :fixtures, (
  Merb::Plugins.config[:sweet_merb_fixures][:fixtures_dir] || (Merb.dir_for(:lib) / :fixtures )), nil
module Merb::Fixtures; end
lib = :sweet_merb_fixtures
require( lib / :dm_associations )
require( lib / :merb_fixtures / :hash )

module Merb::Fixtures
  def self.included(klass)
    klass.class_eval do
      attr_accessor :fixtures
    end
  end

  def load_fixture(*specifies)
    options = {} unless options = extract_options_from_args!(specifies)

    hash = Merb::Fixtures::Hash.new(
      specifies.map{ |s| Merb::Fixtures.load_fixture_file(s)} )

    # TODO the code below is for test environment, 
    # especially used by the way for TestHelper to include Merb::Fixtures module,
    # enable fixtures[:name] method to get a specified named record,
    # but it has not tested yet.
    self.fixtures = hash if self.respond_to? :fixtures= 

    result = hash.store_to_database
    if result == true and options[:report]
      report_successfully_created_records(hash)
    end
    result
  end

  def report_successfully_created_records(hash)
    puts
    puts "Created Records"
    puts "==============="
    hash.records.each do |model, records|
      puts "--> #{records.size} #{model.name}."
    end
  end


  def self.load_fixture_file(specify)
    file = Merb.dir_for(:fixtures) / specify + ".yml" 
    if File.exists? file
      YAML.load_file file 
    else
      raise "Couldn't find the fixture file: #{file}"
    end
  end

  def self.load_fixture(*specifies)
    prepare_database
    k = Class.new
    k.send(:include, Merb::Fixtures)
    i = k.new
    i.load_fixture *specifies
  end


  # Override this method if you need.
  def self.prepare_database
    DataMapper.auto_migrate!
  end

end
