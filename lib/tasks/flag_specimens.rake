namespace :data do

  task :flag_specimen => :environment do
    individual_ids = Individual.joins(isolates: :marker_sequences).distinct.merge(MarkerSequence.with_warnings).pluck(:id)
    individuals_with_issues = []

    individual_ids.each do |individual_id|
      sequences = MarkerSequence.joins(isolate: :individual).distinct.with_warnings.where('individuals.id = ?', individual_id)
      individuals_with_issues << individual_id if (sequences.size > 1)
    end

    individuals_with_issues.each do |individual_id|
      Individual.find(individual_id).update(has_issue: true)
    end
  end
end