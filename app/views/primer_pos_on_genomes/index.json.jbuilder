# frozen_string_literal: true

json.array!(@primer_pos_on_genomes) do |primer_pos_on_genome|
  json.extract! primer_pos_on_genome, :id, :note, :position
  json.url primer_pos_on_genome_url(primer_pos_on_genome, format: :json)
end
