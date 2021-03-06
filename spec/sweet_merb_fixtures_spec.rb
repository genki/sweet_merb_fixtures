require File.dirname(__FILE__) + '/spec_helper'

describe "sweet_merb_fixtures" do
  before do
    Merb::Fixtures.prepare_database
  end

  it "should create records from given hash"  do
    hash = { 
      "parents" => [
        { :name => "ttt" }, 
        { :name => "ooo"}
        ]
    }
    h = Merb::Fixtures::Hash.new(hash.dup)
    h.storage_to_model("parents").should == Parent
    h.store_to_database.should == true
    Parent.all.size.should == 2
    # These are expected because of the behavior of Array
    Parent.get(1).name.should == "ttt"
    Parent.get(2).name.should == "ooo"
  end

  it "should provide the easy way to get a perticulally named record" do
    hash = {
      "parents" => [
        { "name" => "ppp" },
        { "id" => "named", "name" => "named" }
      ]
    }
    h = Merb::Fixtures::Hash.new(hash.dup)
    h.store_to_database.should == true
    Parent.all.size.should == 2
    Parent.get(2).should == h.names[:named]
    Parent.get(2).should == h[:named]
  end


  it "should manage multiple storage at once" do
    hash = {
      "parents" => [ {"name" => "ttt" }, {:name => "ooo"}],
      "children" => [ {"name" => "ooooo", "type" => "boy" }, {"id" => "girl", :name => "ppppp", "type" => "girl"} ]
    }
    h = Merb::Fixtures::Hash.new(hash)
    h.store_to_database.should == true
    Parent.get(1).name.should == "ttt"
    Parent.get(2).name.should == "ooo"
    Child.get(1).name.should == "ooooo"
    Child.get(2).name.should == "ppppp"
    Child.get(2).should == h[:girl]
  end

  it "should recognize the associated records which is represented as nested hashs" do
    hash = {
      "parents" => [ 
        {"name" =>"ttt"}, 
        {"name" => "ooo",
         "children" => [
            { "name" => "ooooo", "type" => "boy"},
            { "name" => "ppppp" , "type" => "boy", "id" => "name"}
         ] 
        }
      ]
    }

    hash_to_separate = hash["parents"][1].dup
    h = Merb::Fixtures::Hash.new(hash_to_separate)
    children = h.separate_children(Parent, hash_to_separate)
    hash_to_separate.has_key?("children").should == false
    children.has_key?("children").should == true

    h = Merb::Fixtures::Hash.new(hash)
    h.store_to_database.should == true
    Parent.count.should == 2
    Child.count.should == 2
    h[:name].parent_id.should == 2
  end

  it "should provides Model#one_to_many_relationships function. " do
    rels = Parent.one_to_many_relationships
    rels.keys.should include(:taggings, :tags, :children)
  end

  it "should provides the way to specify common values in a group of records" do
    hash = {
      "parents" => [ 
        {"name" =>"ttt"}, 
        {"name" => "ooo",
         "children" => 
            { "{ type: girl }" => [
              { "name" => "ooooo"},
              { "name" => "ppppp", "id" => "name"}
            ], 
              "{ type: boy }" => [
              { "name" => "ooooo"},
              { "name" => "ppppp", "id" => "name2"}
            ]
            }
        }
      ]
    }
    h = Merb::Fixtures::Hash.new(hash)
    h.handle_default_value(hash["parents"]).should == hash["parents"]
    resolved =  h.handle_default_value(hash["parents"][1]["children"])
    resolved.should be_a(Array)

    h.store_to_database.should == true
    h.records[Parent].size == 2
    h.records[Child].size == 4
  end

  it "should create the associated records, especially whose relationship is RelathionshipChain" do
    hash = Merb::Fixtures::load_fixture_file("chain")
    hash.should be_a(Hash)
    h = Merb::Fixtures::Hash.new(hash)
    h.store_to_database.should == true
    h.records[Tagging].size.should == 3
    h.records[Tag].size.should == 3
  end

  it "should manage the hash which is nested more than twice" do
    hash = Merb::Fixtures::load_fixture_file("gc")
    hash.should be_a(Hash)
    h = Merb::Fixtures::Hash.new(hash)
    h.store_to_database.should == true
    h.records[GrandChild].should be_a(Array)
    h.records[Parent].size == 1
    h.records[Child].size == 2
    h.records[GrandChild].size == 1
  end

  it "should provide the way to split the fixutre files and reuse created named record" do
    Merb::Fixtures.load_fixture("gc", "chain")
    Parent.count.should == 1
    Child.count.should == 2
    GrandChild.count.should == 1
    Tagging.count.should == 3
    Tag.count.should == 3
  end


  it "should evaluate ERB in YAML file" do
    Merb::Fixtures.load_fixture("erb")
    Parent.count.should == 3
    Parent.get(1).name.should == "a"
    Parent.get(2).name.should == "b"
    Parent.get(3).name.should == "c"
  end

  it "tries to create without the value of association key if its parent record wasn't saved" do
    a = Parent.new
    a.save.should == false
    Merb::Fixtures.load_fixture("parent_failed").should be_a(String) #failure messages
    Parent.count.should be_zero
    Child.get(1).parent_id.should be_nil
  end

  it "should provide fixtures method if module is properly included" do
    load_fixture("parent_failed")
    fixtures[:pochi].name.should == "Pochi"
    fixtures[:tama].name.should == "Tama"
  end

  it "should load fixtures with performing filters as default" do
    load_fixture("chain")
    fixtures[:one].should be_performed_before_create
  end

  it "should load fixtures without performing filters if :skip_filters specified in option" do
    load_fixture("chain", :skip_filters => true)
    fixtures[:one].should_not be_performed_before_create
  end

  it "should be able to pass both String and Symbol as filename to load_fixtures method." do
    load_fixture("parent_failed")
    fixtures[:pochi].name.should == "Pochi"
    self.fixtures = nil
    Merb::Fixtures.prepare_database :force => true
    load_fixture(:parent_failed)
    fixtures[:pochi].name.should == "Pochi"
  end

  it "should have Merb::Fixtures::available_files method to get a list of available fixture files" do
    list = Merb::Fixtures.available_files
    list.should include(:chain)
    list.should include(:erb)
    list.should include(:gc)
    list.should include(:parent_failed)
    list.should include(:users)
  end

  it "should display infomation about available storages when given storage name was wrong" do
    Merb::Fixtures::Hash.available_storages.should include("users") 
    proc do 
      load_fixture("not_available_storage")
    end.should raise_error(RuntimeError, /AvailableStorages/)
  end

end
