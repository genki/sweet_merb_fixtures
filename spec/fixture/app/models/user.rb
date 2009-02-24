class User
  include DataMapper::Resource

  property :id, Serial
  property :login, String
  
  has n, :groups, :through => has(n, :assignments).name
  has n, :owning_groups, :class_name => Group

  validates_present :login
end
