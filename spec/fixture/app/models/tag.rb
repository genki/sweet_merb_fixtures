class Tag
  include DataMapper::Resource
  
  property :id, Serial
  property :name, String, :nullable => false
  property :parents_count, Integer, :nullable => false, :default => 0

  has n, :parents, :through => has(n, :taggings).name

end
