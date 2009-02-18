module DataMapper::Associations
  def one_to_many_relationships
    relationships unless @relationships
    rels = @relationships.values.inject([]) do |result, rel|
      rel.nil? ? result : result.push(rel)
    end
    if :symbol.respond_to? :to_proc
      rels = rels.map(&:values).flatten
    else
      rels = rels.map{|r| r.values }.flatten
    end
    rels.inject({}) do |result, rel|
      if rel.parent_model == self
        if rel.is_a? DataMapper::Associations::RelationshipChain
          result[rel.options[:remote_relationship_name]] = rel
        else
          result[rel.name] = rel
        end
      end
      result
    end
  end
end
