module QueryComponents
  class Suggest < BaseComponent
    SPELLING_FIELD = 'spelling_text'

    def payload
      {
        text: search_term,
        spelling_suggestions: {
          phrase: {
            field: SPELLING_FIELD,
            size: 1,
            direct_generator: [{
              field: SPELLING_FIELD,
              suggest_mode: 'missing',
              sort: 'score'
            }]
          }
        }
      }
    end
  end
end
