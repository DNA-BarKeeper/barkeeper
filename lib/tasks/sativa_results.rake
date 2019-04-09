namespace :data do

  desc 'Create csv table with SATIVA results for given IDs'
  task sativa_results: :environment do
    ids = %w(GBoL2691 GBoL2694 GBoL2696 GBoL2711 GBoL2718 GBoL2695 GBoL2724 GBoL2726 GBoL2729 GBoL2731 GBoL2732
GBoL2740 GBoL2744 GBoL2748 GBoL2770 GBoL2776 GBoL2759 GBoL2787 GBoL2815 GBoL2819 GBoL2790 GBoL2846 GBoL2834
GBoL2593 GBoL2630 GBoL2631 GBoL2641 GBoL2649 GBoL2658 GBoL2666 GBoL2672 GBoL2682 GBoL3650 GBoL3652 GBoL3658
GBoL3661 GBoL3662 GBoL3697 GBoL3699 GBoL3700 GBoL3703 GBoL3704 GBoL3705 GBoL3727 GBoL3707 GBoL3701 GBoL3739
GBoL3740 GBoL3457 GBoL3467 GBoL3459 GBoL3474 GBoL3472 GBoL3476 GBoL3477 GBoL3481 GBoL3482 GBoL3505 GBoL3517
GBoL3484 GBoL3521 GBoL3522 GBoL3523 GBoL3535 GBoL3537 GBoL3554 GBoL3568 GBoL3569 GBoL3573 GBoL3571 GBoL3588
GBoL3589 GBoL3590 GBoL3591 GBoL3592 GBoL3593 GBoL3594 GBoL3595 GBoL3596 GBoL3597 GBoL3603 GBoL3613 GBoL3615
GBoL3616 GBoL3617 GBoL3618 GBoL3619 GBoL3641 GBoL3625 GBoL3626 GBoL3627 GBoL3635 GBoL3636 GBoL3606 GBoL3637
GBoL3541)

    isolates = Isolate.includes(individual: :species).where(lab_nr: ids)
    analyses = [14, 15, 21, 22]
    # analyses = [7, 18, 19, 20]

    CSV.open('sativa_results_land_plants.csv', 'wb') do |csv|
      csv_header = ['Isolate', 'Original label']

      Marker.gbol_marker.each do |m|
        csv_header << "#{m.name} - Proposed label"
        csv_header << "#{m.name} - Confidence"
      end

      csv << csv_header

      isolates.each do |i|
        line = []
        line << i.lab_nr
        species = i.individual&.species&.composed_name
        if species
          line << species
        else
          line << ""
        end

        Marker.gbol_marker.each do |m|
          mislabel = i.marker_sequences.where(marker: m)&.first&.mislabels&.where(mislabel_analysis_id: analyses)&.first
          if mislabel
            line << mislabel.proposed_label
            line << mislabel.confidence.to_f
          else
            line << ""
            line << ""
          end
        end

        csv << line
      end
    end
  end

  desc 'Create FASTA and taxonomy files for Susis analyses'
  task analysis_files: :environment do
    ids = %w(GBoL2691 GBoL2694 GBoL2696 GBoL2711 GBoL2718 GBoL2695 GBoL2724 GBoL2726 GBoL2729 GBoL2731 GBoL2732
GBoL2740 GBoL2744 GBoL2748 GBoL2770 GBoL2776 GBoL2759 GBoL2787 GBoL2815 GBoL2819 GBoL2790 GBoL2846 GBoL2834
GBoL2593 GBoL2630 GBoL2631 GBoL2641 GBoL2649 GBoL2658 GBoL2666 GBoL2672 GBoL2682 GBoL3650 GBoL3652 GBoL3658
GBoL3661 GBoL3662 GBoL3697 GBoL3699 GBoL3700 GBoL3703 GBoL3704 GBoL3705 GBoL3727 GBoL3707 GBoL3701 GBoL3739
GBoL3740 GBoL3457 GBoL3467 GBoL3459 GBoL3474 GBoL3472 GBoL3476 GBoL3477 GBoL3481 GBoL3482 GBoL3505 GBoL3517
GBoL3484 GBoL3521 GBoL3522 GBoL3523 GBoL3535 GBoL3537 GBoL3554 GBoL3568 GBoL3569 GBoL3573 GBoL3571 GBoL3588
GBoL3589 GBoL3590 GBoL3591 GBoL3592 GBoL3593 GBoL3594 GBoL3595 GBoL3596 GBoL3597 GBoL3603 GBoL3613 GBoL3615
GBoL3616 GBoL3617 GBoL3618 GBoL3619 GBoL3641 GBoL3625 GBoL3626 GBoL3627 GBoL3635 GBoL3636 GBoL3606 GBoL3637
GBoL3541)

    Marker.gbol_marker.each do |marker|
      ids_marker = ids.collect { |id| id + "_#{marker.name}" }
      marker_sequences = MarkerSequence.where(name: ids_marker)
      fasta = "2195_#{marker.name}.SANGER.fasta"
      taxonomy = "2195_#{marker.name}.SANGER.tax"

      File.open(fasta, 'w+') do |f|
        f.write(MarkerSequenceSearch.fasta(marker_sequences, metadata: false))
      end

      File.open(taxonomy, 'w+') do |f|
        f.write(MarkerSequenceSearch.taxonomy_file(marker_sequences))
      end
    end
  end
end