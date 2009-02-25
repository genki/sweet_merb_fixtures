class User
  include DataMapper::Resource

  property :id, Serial
  property :login, String
  
  has n, :joining_groups, :through => has(n, :assignments).name, :child_model => Group
  has n, :owning_groups, :class_name => Group

  validates_present :login
end
