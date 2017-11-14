require 'ostruct'

module Prmd
  class Link
    def initialize(link_schema)
      @link_schema = link_schema
    end

    def required_and_optional_parameters
      @params = {required: {}, optional: {} }
      recurse_properties(Schema.new(@link_schema["schema"]), "")
      [@params[:required], @params[:optional]]
    end

    private

    def recurse_properties(schema, prefix ="", parent_required= false )
      return unless schema.has_properties?

      schema.properties.keys.each do |prop_name|
        prop = schema.properties[prop_name]
        pref = "#{prefix}#{prop_name}"
        required = schema.property_is_required?(prop_name)

        handle_property(prop, pref, required)
      end
    end

    def handle_property(property, prefix, required = false)
      case
      when property_is_object?(property["type"])
        recurse_properties(Schema.new(property), "#{prefix}:", required)
      when property_is_array_of_objects?(property)
        recurse_properties(Schema.new(property["items"]), "#{prefix}:", required)
      else
        categorize_parameter(prefix, property, required)
      end
    end

    def property_is_object?(type)
      return false unless type
      type == "object" || type.include?("object")
    end

    def property_is_array_of_objects?(property)
      type = property["type"]
      return false unless property && type
      (type == "array" || type.include?("array")) && property["items"] && property_is_object?(property["items"]["type"])
    end

    def categorize_parameter(name, param,  required=false)
      @params[(required ? :required : :optional)][name] = param
    end

    class Schema < OpenStruct
      def has_properties?
        self.properties && !self.properties.empty?
      end

      def property_is_required?(property_name)
        return false unless required
        return required.include?(property_name)
      end
    end
  end
end
