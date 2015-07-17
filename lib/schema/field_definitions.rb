require "json"
require "schema/field_types"

FieldDefinition = Struct.new("FieldDefinition", :name, :type, :es_config, :description, :children, :allowed_values)

class FieldDefinition
  # Merge this field definition with another one.
  #
  # Assumes that the definitions are for the same field (but probably for a
  # different document type).  Therefore, the only thing that can differ is the
  # allowed_values setting, so we only have to do anything if allowed_values
  # are set.
  def merge(other)
    unless other.nil?
      if other.allowed_values
        result = self.clone
        result.allowed_values = ((result.allowed_values || []) + other.allowed_values).uniq
        return result
      end
    end
    self
  end
end

class FieldDefinitionParser
  def initialize(config_path)
    @config_path = config_path
  end

  def parse
    @field_types = FieldTypes.new(@config_path)
    parse_definitions(load_json)
  end

private

  def parse_definitions(raw)
    definitions = {}
    raw.each_pair do |field_name, value|
      # Look up the field type
      type_name = value.delete("type")
      if type_name.nil?
        raise %{Missing "type" in field definition "#{field_name}" in "#{definitions_file_path}"}
      end
      type = @field_types.get(type_name)

      # Look up the children details
      children_hash = value.delete("children")
      if children_hash
        if type.children != "named"
          raise %{Named children not valid for type "#{type_name}" in field definition "#{field_name}" in "#{definitions_file_path}"}
        end
        children = parse_definitions(children_hash)
      end

      es_config = type.es_config
      if children
        es_config = es_config.merge({"properties" => es_config_for_child_fields(children)})
      end

      definition = FieldDefinition.new(
        field_name,
        type,
        es_config,
        value.delete("description") || "",
        children,
      )

      unless value.empty?
        raise %{Unknown keys (#{value.keys.join(", ")}) in field definition "#{field_name}" in "#{definitions_file_path}"}
      end
      definitions[field_name] = definition
    end
    definitions
  end

  def es_config_for_child_fields(children)
    result = {}
    children.each { |field_name, definition|
      result[field_name] = definition.es_config
    }
    result
  end

  def load_json
    JSON.parse(File.read(definitions_file_path, encoding: 'UTF-8'))
  end

  def definitions_file_path
    File.join(@config_path, "field_definitions.json")
  end
end
