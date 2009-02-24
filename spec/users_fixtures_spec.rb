require File.dirname(__FILE__) + '/spec_helper'

describe "users fixtures" do
  before :all do
    load_fixture("users")
  end

  it "should load fixtures" do
    User.count.should >= 1
    Group.count.should >= 1
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
      @yukiko.assignments.count.should == 1
    end
  end
end
