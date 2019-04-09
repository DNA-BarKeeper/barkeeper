# frozen_string_literal: true

namespace :data do
  task download_course_fasta: :environment do
    contig_names = %w(GBoL2846_trnk-matk GBoL2834_trnk-matk GBoL2658_trnk-matk GBoL2666_trnk-matk GBoL3652_trnk-matk
    GBoL3662_trnk-matk GBoL3467_trnk-matk GBoL3474_trnk-matk GBoL2696_its GBoL2740_its GBoL2748_its GBoL2759_its
    GBoL3571_its GBoL3595_its GBoL3596_its)

    fasta_str = +''

    contig_names.each do |contig_name|
      contig = Contig.in_project(5).where('contigs.name ILIKE ?', contig_name).first

      if contig.partial_cons_count == 1
        fasta_str += ">#{contig.name}\n"
        fasta_str += "#{contig.partial_cons.first.aligned_sequence.scan(/.{1,80}/).join("\n")}\n"
      else
        puts "More or less than one partial con: #{contig.name} (#{contig.partial_cons_count})"
      end
    end

    puts fasta_str
  end
end
