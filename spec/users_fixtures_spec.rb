require File.dirname(__FILE__) + '/spec_helper'
require "pp"

describe "users fixtures" do
  before :all do
    DataMapper.auto_migrate!
    load_fixture("users")
  end

  it "should load fixtures" do
    User.count.should == 2
    Group.count.should == 2
    Assignment.count.should == 2
  end

  it "should prepare named fixtures" do
    fixtures[:yukiko].model == User
    fixtures[:yukiko].login == "yukiko"
    fixtures[:taro].model == User
    fixtures[:taro].login == "taro"
    fixtures[:merbist].model == Group
    fixtures[:merbist].name == "Merbist"
    fixtures[:rubyist].model == Group
    fixtures[:rubyist].name == "Rubyist"

    fixtures[:yukiko_is_merbist].should_not nil
    fixtures[:yukiko_is_merbist].model == Assignment
  end

  it "should set specified parameters to the middle model of many-to-many associations" do
    fixtures[:yukiko_is_merbist].errors.should be_empty
    fixtures[:yukiko_is_merbist].role.should == "owner"
  end

  describe "yukiko" do
    before do
      @yukiko = User.all(:login => 'yukiko')
    end

    it "should exist" do
      @yukiko.should be_present
    end

    it "should have 1 owning group" do
      @yukiko.owning_groups.count.should == 1
      @yukiko.owning_groups.first.name.should == "Merbist"
    end

    it "should have 1 assignment" do
      @yukiko.assignments.count.should == 2
    end

    it "should join a group as a role of owner" do
      @yukiko.assignments.each do |assign|
        if assign.group.name == "Merbist"
          assign.role.should == "owner"
        end
      end
    end

    # TODO: this spec fails now.
    it "should have Groups as a :joining_groups" do
      @yukiko.joining_groups.each do |group|
        group.model.should == Group
      end
    end

  end
end
