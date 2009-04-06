require File.dirname(__FILE__) + '/spec_helper'

describe "ExampleGroup" do
  
  before(:all) do

    # make sure that users table has no records first.
    User.auto_migrate!

    # load fixtures when :given_fixture option is given
    options = self.class.options
    if given_fixture_name = (options[:given_fixture] or options[:fixture])
      load_fixture(*Array(given_fixture_name))
    end

  end

  describe "when neigther :given_fixture or :fixture option was specified" do
    it "should not load anything" do
      User.count.should == 0
    end
  end

  share_examples_for "A fixture option given as a Symbol" do

    it "should load fixtures of a given file name" do
      User.count.should == 2
      User.get!(1).login.should == "taro"
      User.get!(2).login.should == "jiro"
    end

  end

  share_examples_for "A fixture option given as an Array" do

    it "should load fixtures of multiple files" do
      User.count.should == 5
      User.get!(3).login.should == "ume"
      User.get!(4).login.should == "momo"
      User.get!(5).login.should == "sakura"
    end

  end

  describe "when :given_fixture option was given as a Symbol",
    :given_fixture => :given_data do

    it_should_behave_like "A fixture option given as a Symbol"

  end

  describe "when :given_fixture option was given as an Array",
    :given_fixture => [:given_data, :another_given_data] do

    it_should_behave_like "A fixture option given as an Array"

  end

  describe "when :fixture option was given as a Symbol",
    :fixture => :given_data do

    it_should_behave_like "A fixture option given as a Symbol"
      
  end

  describe "when :fixture option was given as an Array",
    :fixture => [:given_data, :another_given_data] do

    it_should_behave_like "A fixture option given as an Array"

  end

end
