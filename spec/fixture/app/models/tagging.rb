class Tagging
  include DataMapper::Resource
  
  property :id, Serial

  belongs_to :tag
  belongs_to :parent

end
