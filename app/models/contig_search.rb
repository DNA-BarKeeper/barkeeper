class ContigSearch < ApplicationRecord
  def contigs
    contigs ||= find_contigs
  end

  private
  def find_contigs
    contigs = Contig.order(:name)
    contigs = contigs.where("contigs.name ilike ?", "%#{name}%") if name.present?

    if assembled != 'both'
      contigs = contigs.where(assembled: true) if (assembled == 'assembled')
      contigs = contigs.where(assembled: false) if (assembled == 'unassembled')
    end

    if verified != 'both'
      contigs = contigs.where(verified: true) if (verified == 'verified')
      contigs = contigs.where(verified: false) if (verified == 'unverified')
    end

    contigs = contigs.where(marker_id: marker_id) if marker_id.present?

    contigs = contigs.joins(isolate: { individual: {species: :family}}).where(families: {order_id: order_id}) if order_id.present?

    contigs = contigs.joins(isolate: { individual: {species: :family}}).where("families.name ilike ?", "%#{family}%") if family.present?

    contigs = contigs.joins(isolate: { individual: :species }).where("species.composed_name ilike ?", "%#{species}%") if species.present?

    contigs = contigs.joins(isolate: :individual).where("individuals.specimen_id ilike ?", "%#{specimen}%") if specimen.present?

    contigs = contigs.where("contigs.created_at >= ?", min_age.midnight) if min_age.present?
    contigs = contigs.where("contigs.created_at <= ?", max_age.end_of_day) if max_age.present?

    contigs = contigs.where("contigs.updated_at >= ?", min_update.midnight) if min_update.present?
    contigs = contigs.where("contigs.updated_at <= ?", max_update.end_of_day) if max_update.present?

    contigs
  end
end