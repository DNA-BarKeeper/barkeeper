# frozen_string_literal: true

PgSearch.multisearch_options = {
  using: { tsearch: { prefix: true, any_word: true, dictionary: "simple" }, trigram: { threshold: 0.01 } }
}
