require 'matcher_set'
require 'search_config'
require 'registry'

module UnifiedSearch
  class SuggestionBlacklist < Struct.new(:registries)
    STRINGS_WITH_DIGITS = /\d/

    def should_correct?(string)
      ! ignore_list.include?(string.to_s.downcase)
    end

    def ignore_list
      MatcherSet.new(regex_patterns + words_from_ignore_file + organisation_acronyms)
    end

  private

    # Don't correct words with digits as these are often names of forms.
    def regex_patterns
      [STRINGS_WITH_DIGITS]
    end

    # Custom list of words we don't want to correct because they're actually
    # correct, or sensitive.
    def words_from_ignore_file
      @@words_from_ignore_file ||= YAML.load_file('config/suggest/ignore.yml')
    end

    # Organisation acronyms like `dvla` and 'gds' are sometimes considered
    # spelling errors. We use the organisation index to ignore all acronyms.
    def organisation_acronyms
      organisation_registry = registries.organisations
      organisation_registry.all.map(&:acronym).compact.map(&:downcase)
    end
  end
end
