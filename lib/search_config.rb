require "yaml"
require "elasticsearch/search_server"

class SearchConfig

  def search_server
    Elasticsearch::SearchServer.new(
      ENV['QUIRKAFLEEG_ELASTICSEARCH_LOCATION'] || elasticsearch["base_uri"],
      elasticsearch_schema,
      index_names
    )
  end

  def index_names
    elasticsearch["index_names"]
  end

  def elasticsearch_schema
    @elasticsearch_schema ||= config_for("elasticsearch_schema")
  end

  def elasticsearch
    @elasticsearch ||= config_for("elasticsearch")
  end

  def document_series_registry_index
    elasticsearch["document_series_registry_index"]
  end

  def document_collection_registry_index
    elasticsearch["document_collection_registry_index"]
  end

  def organisation_registry_index
    elasticsearch["organisation_registry_index"]
  end

  def topic_registry_index
    elasticsearch["topic_registry_index"]
  end

  def world_location_registry_index
    elasticsearch["world_location_registry_index"]
  end

  def govuk_index_names
    elasticsearch["govuk_index_names"]
  end

private
  def config_for(kind)
    YAML.load_file(File.expand_path("../#{kind}.yml", File.dirname(__FILE__)))
  end
end
