class Parent
  include DataMapper::Resource

  property :id, Serial
  property :name, String, :nullable => false, :max => 25

  has n, :children
  has n, :tags, :through => has(n, :taggings).name

  before :create do
    @performed_before_create = true
  end

  def performed_before_create?
    !!@performed_before_create
  end
end
