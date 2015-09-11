module QueryComponents
  class BestBets < BaseComponent
    def wrap(original_query)
      return original_query if debug[:disable_best_bets] || no_bets?

      result = {
        bool: {
          should: [original_query] + best_bet_queries
        }
      }

      unless worst_bets.empty?
        result[:bool][:must_not] = [{ ids: { values: worst_bets } }]
      end

      result
    end

    private

    # `best_bet_queries` make sure documents with the specified IDs are returned
    # by elasticsearch. It also adds a huge boost factor for these results, to
    # make them on top of the search results page.
    #
    # Note that bets with a lower `position` will turn up higher than bets with
    # a lower `position`.
    def best_bet_queries
      bb_max_position = best_bets.keys.max
      best_bets.map do |position, links|
        {
          function_score: {
            query: {
              ids: { values: links },
            },
            boost_factor: (bb_max_position + 1 - position) * 1_000_000,
          }
        }
      end
    end

    def no_bets?
      best_bets.empty? && worst_bets.empty?
    end

    def best_bets
      @best_bets ||= best_bets_checker.best_bets
    end

    def worst_bets
      @worst_bets ||= best_bets_checker.worst_bets
    end

    def best_bets_checker
      @best_bets_checker ||= BestBetsChecker.new(search_term)
    end
  end
end
