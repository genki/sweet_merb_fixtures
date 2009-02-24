class Group
  include DataMapper::Resource

  property :id, Serial
  property :name, String

  has n, :users, :through => has(1..n, :assignments).name
  belongs_to :user

  validates_present :name, :user
end
