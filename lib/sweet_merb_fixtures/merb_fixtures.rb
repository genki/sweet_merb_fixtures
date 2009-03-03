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
    
    if options[:skip_filters]
      require 'sweet_merb_fixtures/merb_fixtures/skip_filters'
      hash.extend SkipFilters
    end

    self.fixtures = hash if self.respond_to? :fixtures= 

    result = hash.store_to_database
    if result == true and options[:report]
      hash.code_to_report
    end
    result
  end

  def self.load_fixture_file(specify, options={})
    file = fixture_file(specify)
    if File.exists? file
      return IO::read file if options[:plain]
      Erubis.load_yaml_file file 
    else
      raise "Couldn't find the fixture file: #{file}"
    end
  end

  def self.fixture_file(specify)
    Merb.dir_for(:fixtures) / specify + ".yml" 
  end

  def self.available_files
    dir = Merb.dir_for(:fixtures)
    Dir[dir / :** / "**.yml"].map { |path| path.match %r{^#{dir}/(.*)\.yml}; $1.to_sym }
  end

  def self.cat_file(specify)
    print(load_fixture_file specify, :plain => true)
  end

  def self.load_fixture(*specifies)
    prepare_database
    k = Class.new
    k.send(:include, Merb::Fixtures)
    i = k.new
    i.load_fixture *specifies
  end


  # Override this method if you need.
  def self.prepare_database(options={})
    if Merb::Plugins.config[:sweet_merb_fixtures][:auto_migrate] or options[:force]
      DataMapper.auto_migrate!
    end
  end

  def self.records_for_dump
    records = {}
    DataMapper::Resource.descendants.each do |model|
      records_of_this_model = model.all
      records.merge! model.storage_name => records_of_this_model.map{|r| r.attributes } unless records_of_this_model.empty?
    end
    records
  end

  def self.records_for_dump_with_except_or_only(options={})
    records = records_for_dump
    case
      when options[:except]
        excepts = Array(options[:except]).map {|k| k.to_s}
        records.except *excepts
      when options[:only]
        onlys = Array(options[:only]).map {|k| k.to_s}
        records.only *onlys
    else
      records
    end
  end

  def self.dump(specify="dumped", options={})
    if (! File.exists? fixture_file(specify)) or options.delete(:force)
      io = open(fixture_file(specify), "w")
      io.write records_for_dump_with_except_or_only(options).to_yaml
      io.close
    end
  end

end

unless Merb::Plugins.config[:sweet_merb_fixtures][:disable_MF]
  # a short alias 
  MF = Merb::Fixtures
end
