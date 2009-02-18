class GrandChild
  include DataMapper::Resource
  
  property :id, Serial
  property :name, String, :nullable => false

  belongs_to :child

end
