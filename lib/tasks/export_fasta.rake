# frozen_string_literal: true

namespace :data do
  task download_course_fasta: :environment do
    contig_names = %w(GBoL2846_trnk-matk GBoL2834_trnk-matk GBoL2658_trnk-matk GBoL2666_trnk-matk GBoL3652_trnk-matk
    GBoL3662_trnk-matk GBoL3467_trnk-matk GBoL3474_trnk-matk GBoL2696_its GBoL2740_its GBoL2748_its GBoL2759_its
    GBoL3571_its GBoL3595_its GBoL3596_its)

    fasta_str = +''

    contig_names.each do |contig_name|
      contig = Contig.in_project(current_project_id).where('contigs.name ILIKE ?', contig_name).first

      if contig
        fasta_str += Contig.fasta(contig, [])
      end
    end

    fasta_str
  end
end
