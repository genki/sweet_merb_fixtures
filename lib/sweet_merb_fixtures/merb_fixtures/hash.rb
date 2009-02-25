module Merb::Fixtures

  # Merb::Fixtures::Hash.new(hash).store_to_database
  class Hash
    attr_accessor :records, :names

    chainable do

      def code_to_create_record(model, hash)
        model.create(hash)
      end

      def code_to_create_child_record(parent_record, relation_name, hash)
        if parent_record.errors.empty?
          parent_record.send(relation_name).create(hash)       
        else
          parent_record.model.relationships[relation_name].child_model.create(hash)
        end
      end

      def code_to_report_errors(errors)
        errors.map{|record| "A #{record.model.name.snake_case}:#{record.errors.full_messages.join(",")}" }.join(", ")
      end

      def code_to_report
        puts
        puts "Created Records"
        puts "==============="
        records.each do |model, records|
          puts "--> #{records.size} #{model.name}."
        end
      end

    end


    def initialize(hashs)
      @hashs = hashs.is_a?(::Hash) ? [hashs] : hashs
      @records = ::Hash.new
      @names = Mash.new
    end

    def [](name)
      @names[name]
    end

    # Make simple @records[Model] = [records] from hash loaded from fixture yaml file,
    # also Merb::Fixtures::Hash#[] is available to access named records.
    def store_to_database
      @hashs.each do |h|
        @hash = h
        @hash.each_pair do |key, value|
          handle_hashs(key, value)
        end
      end
      all_valid?
    end

    # Handling array of hashs
    # 1. get the base model from key.
    # 2. resolve default values and make value into an array of hashs  if value is a Hash.
    # 3. process each of an array of hashs one by one
    def handle_hashs(key, value)
      if key.is_a? DataMapper::Model
        model = key
      else
        raise "expected #{key} was a storage name but wasn't" unless model = storage_to_model( key )
      end
      hashs = handle_default_value(value)
      hashs.each do |hash|
        record = handle_a_hash(model, hash)
        yield(record) if block_given?
      end
    end

    # First, create a parent record.
    def handle_a_hash(parent_model, hash)
      children = separate_children(parent_model, hash)
      parent_record = create_record parent_model, hash

      unless children.empty?
        let_parent_create_their_children(parent_record, children)
      end

      parent_record
    end


    # Then, let the parent create their children
    def let_parent_create_their_children(parent_record, children)
      children.each do |child_relation_name, child_value|
        relationship = parent_record.model.relationships[child_relation_name.to_sym]

        case relationship
          when DataMapper::Associations::RelationshipChain
            handle_many_to_many_relationship(relationship, parent_record, child_value)

          when DataMapper::Associations::Relationship
            handle_one_to_many_relationship(relationship, parent_record, child_value)
        end
      end
    end

    def handle_one_to_many_relationship(relationship, parent_record, child_value)
    # 
    # When creating a parent record, we use
    #   Parent.create(params)
    # but when creating a child record or a grandchild record ..etc we use this code.
    #   parent.children.create(params)
    #
    # It's nessecary to manage the difference.
    #
      child_model = parent_record.model.relationships[relationship.name].child_model
      child_hashs = handle_default_value(child_value)

      child_hashs.each do |hash|

        grand_children = separate_children(child_model, hash) 
        child_record = create_record(child_model, hash) do |child_model, givenhash|
          code_to_create_child_record(parent_record, relationship.name, givenhash)
        end

        # Now, we have to let the child create their parent's grandchildren.
        unless grand_children.empty?
          let_parent_create_their_children child_record, grand_children
        end

      end
    end

    def handle_many_to_many_relationship(relationship, parent_record, child_value)
    # 
    # The situation is different from above case.
    #
    # First create records of remote_relationship's parent_model,
    # then create records of near_relationship's child_model (which is also remote_relationship's child_model) 
    # because it seems the function to create records through relationship chain haven't been provided or stable.
    #    
      remote = relationship.send(:remote_relationship)
      near = relationship.send(:near_relationship)
      child = near.child_model # same as remote.child_model
      parent_key = "#{parent_record.model.name.snake_case}_id".to_sym

      handle_hashs(remote.parent_model, child_value) do |remote_parent_record|
        create_record(child, { parent_key => parent_record.id }) do |child, givenhash|
          code_to_create_child_record(remote_parent_record, near.name, givenhash)
        end
      end
    end

    def handle_default_value(val)
      if val.is_a? Array
        return val
      elsif val.is_a? ::Hash
        array = []
        val.each do |k, v|
          if v.is_a? Array
            default_value = YAML.load(k)
            v.map do |hash|
              array << hash.merge(default_value)
            end
          elsif v.is_a? ::Hash
            v = handle_default_value v 
          else
            raise "can't be happen"
          end
        end
        return array
      else
        raise "can't be happen"
      end
    end


    # Create the record from given model and hash.
    #
    # if block given, 
    #   it is used to replace the code which creates records.
    # if there are already same named record, 
    #   the return value would be the record which has created before.
    
    def create_record(model, hash)
      name = delete_named_key(hash)
      if record = @names[name]

        # TODO> What should I check?
        # * I should raise error when either
        #   - the given model or
        #   - the given parameters
        #   is apprentlly diffrent from the record created before.

      else
        @records[model] ||= []
        unless block_given?
          record = code_to_create_record(model, hash)
        else
          record = yield model, hash
        end
        @records[model] << record
        @names[name] = record if name
      end
      record
    end

    def all_valid?
      errors = []
      @records.values.flatten.each do |record| 
        errors << record unless record.errors.empty? 
      end
      errors.empty? ? true : code_to_report_errors(errors)
    end

    def separate_children(model, hash)
      children = model.one_to_many_relationships.keys
      hash.keys.inject({}) do |result, key|
        if children.include?(key.to_sym)
          result[key] = hash.delete(key)
          result
        else
          result
        end
      end
    end

    def delete_named_key(hash)
      if hash["id"] and hash["id"].is_a?(String)
        hash.delete "id"
      end
    end

    def storage_to_model(target)
      DataMapper::Resource.descendants.inject(nil) { |result, m| result = m if m.storage_name == target; result }
    end


  end

end
