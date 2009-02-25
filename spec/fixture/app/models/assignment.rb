class Assignment
  include DataMapper::Resource

  property :id, Serial
  property :role, String

  belongs_to :user

  # This line is not nessesary for this test but enables both assignment.group and assignment.joining_group.
  belongs_to :group 

  # for :through association
  belongs_to :joining_group, :class_name => Group  
end
