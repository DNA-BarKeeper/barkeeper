# frozen_string_literal: true

namespace :data do
  task flag_specimen: :environment do
    individual_ids = Individual.joins(isolates: :marker_sequences).distinct.merge(MarkerSequence.unsolved_warnings).pluck(:id)
    individuals_with_issues = []

    individual_ids.each do |individual_id|
      sequences = MarkerSequence.joins(isolate: :individual).distinct.unsolved_warnings.where('individuals.id = ?', individual_id)
      individuals_with_issues << individual_id if sequences.size > 1
    end

    individuals_with_issues.each do |individual_id|
      Individual.find(individual_id).update(has_issue: true)
    end
  end

  task unflag_specimen: :environment do
    individuals_with_flag = Individual.where(has_issue: true)

    individuals_with_flag.each do |individual|
      sequences = MarkerSequence.joins(isolate: :individual).distinct.unsolved_warnings.where('individuals.id = ?', individual.id)
      individual.update(has_issue: false) if sequences.size < 2
    end
  end
end
