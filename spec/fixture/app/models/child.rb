class Child
  include DataMapper::Resource
  
  property :id, Serial
  property :name, String, :nullable => false
  property :type, String, :in => %w[boy girl], :nullable => false

  belongs_to :parent
  has n, :grand_children

end
