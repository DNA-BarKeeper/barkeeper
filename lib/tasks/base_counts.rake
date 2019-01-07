# frozen_string_literal: true

namespace :data do
  desc "fill reads' basecount"

  task base_counts: :environment do
    PrimerRead.where(base_count: nil).find_each(batch_size: 100) do |p|
      if p.sequence
        p.base_count = p.sequence.length
        p.save!
        puts p.name
      end
    end

    puts 'Done.'
  end
end
