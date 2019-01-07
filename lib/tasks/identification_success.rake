# frozen_string_literal: true

namespace :data do
  desc 'Calculate identification success of marker'

  task :identification_success, [:marker] => [:environment] do |_t, args|
    marker = Marker.find_by_name(args[:marker])

    sequences = MarkerSequence.joins(isolate: [individual: :species])
                              .where(marker: marker.id)
                              .distinct
                              .group_by { |ms| ms.isolate.individual.species.species_component }

    otus = sequences.map { |k, v| [k, v.collect(&:sequence)] }.to_h

    unidentifiable = []

    # Iterate over all OTUs
    otus.each do |otu, sequences|
      remaining = otus.except(otu).values.flatten # All sequences except those from this OTU

      catch :otu do
        # Iterate over all sequences of this OTU
        sequences.each do |seq1|
          # Compare sequence to all other sequences
          remaining.each do |seq2|
            if sequence_identical?(seq1, seq2)
              unidentifiable << otu
              throw :otu # Move on to next OTU if this one has sequence that is not unique
            end
          end
        end
      end
    end

    p unidentifiable
    puts unidentifiable.size
  end

  def sequence_identical?(seq1, seq2)
    ignore = %w[? N R Y S W M K B D H V]

    seq1.split('').each_with_index do |c1, i|
      c2 = seq2[i]

      next if ignore.include?(c1) || ignore.include?(c2)

      if c1 == c2
        next
      else
        return false
      end
    end

    true
  end
end
