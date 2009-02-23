module Merb::Fixtures
  module SkipFilters
    def code_to_create_record(model, hash)
      resource = model.new(hash)
      save_resource_without_filters(resource)
    end

    def code_to_create_child_record(parent_record, relation_name, hash)
      resource = if parent_record.errors.empty?
        parent_record.send(relation_name).new(hash)       
      else
        parent_record.model.relationships[relation_name].child_model.new(hash)
      end
      save_resource_without_filters(resource)
    end

  private
    def save_resource_without_filters(resource)
      def resource.create
        hookable__create_nan_before_advised
      end
      resource.save
      (class << resource; self end).class_eval{send :remove_method, :create}
      resource
    end
  end
end
