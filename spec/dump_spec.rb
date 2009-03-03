require File.dirname(__FILE__) + '/spec_helper'
require "pp"

describe "create yaml file from records" do
  before :all do
    DataMapper.auto_migrate!
    load_fixture("users")
  end

  it "there is records_for_dump method to prepare" do
    records = MF.records_for_dump 
    records.should be_a(Hash)
    records.keys.should include("users")
    records.keys.should include("groups")
    records.keys.should include("assignments")
  end

  it "dump to fixtures directory" do
    MF.dump("test")
    File.exists?(MF.fixture_file("test")).should be
    FileUtils.rm MF.fixture_file("test")
    File.exists?(MF.fixture_file("test")).should_not be
  end

  it "result from dumped file is same as original" do
    # Original
    original_records = MF.records_for_dump
    MF.dump("test")

    # Restore
    DataMapper.auto_migrate!
    load_fixture("test")
    restored_records = MF.records_for_dump

    original_records.should == restored_records

    FileUtils.rm MF.fixture_file("test")
  end
end
