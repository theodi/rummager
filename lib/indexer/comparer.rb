module Indexer
  class Comparer
    class MissingIdOrType < StandardError; end

    DEFAULT_FIELDS_TO_IGNORE = ["popularity"].freeze

    def initialize(old_index_name, new_index_name, ignore: DEFAULT_FIELDS_TO_IGNORE, io: STDOUT)
      @old_index_name = old_index_name
      @new_index_name = new_index_name
      @field_to_ignore = ignore
      @io = io
    end

    def run
      outcomes = Hash.new(0)

      log "processing: #{@old_index_name}/#{@new_index_name}"

      CompareEnumerator.new(@old_index_name, @new_index_name).each do |old_item, new_item|
        if old_item == CompareEnumerator::NO_VALUE
          outcomes[:added_items] += 1
        elsif new_item == CompareEnumerator::NO_VALUE
          outcomes[:removed_items] += 1
        else
          fields = changed_fields(old_item, new_item)
          if fields.any?
            outcomes[:changed] += 1
            outcomes[:"changes: #{fields.join(',')}"] += 1
          else
            outcomes[:unchanged] += 1
          end
        end
      end

      outcomes
    end

    def search_config
      @search_config ||= SearchConfig.new
    end

    def changed_fields(old_item, new_item)
      return [] if reject_fields(old_item) == reject_fields(new_item)

      keys = (old_item.keys | new_item.keys) - @field_to_ignore
      keys.select { |key| old_item[key] != new_item[key] }.sort
    end

    def reject_fields(hash)
      hash.reject { |k, _| @field_to_ignore.include?(k) }
    end


    def log(msg)
      @io.puts "#{Time.now}: #{msg}"
    end
  end
end