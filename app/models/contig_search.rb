class ContigSearch < ApplicationRecord
  def contigs
    contigs ||= find_contigs
  end

  private
  def find_contigs
    contigs = Contig.order(:name)
    contigs = contigs.where("name ilike ?", "%#{name}%") if name.present?

    contigs = contigs.where(assembled: true) if assembled
    contigs = contigs.where(assembled: false) if unassembled

    contigs = contigs.where(verified: true) if verified
    contigs = contigs.where(verified: false) if unverified

    contigs = contigs.where(marker_id: marker_id) if marker_id.present?

    contigs = contigs.joins(isolate: { individual: {species: :family}}).where(families: {order_id: order_id}) if order_id.present?

    contigs = contigs.joins(isolate: { individual: {species: :family}}).where("families.name ilike ?", "%#{family}%") if family.present?

    contigs = contigs.joins(isolate: { individual: :species }).where("species.composed_name ilike ?", "%#{species}%") if species.present?

    contigs = contigs.joins(isolate: :individual).where("individuals.specimen_id ilike ?", "%#{specimen}%") if specimen.present?
    #
    # contigs = contigs.where("created_at >= ?", min_age) if min_age.present?
    # contigs = contigs.where("created_at <= ?", max_age) if max_age.present?
    #
    # contigs = contigs.where("updated_at >= ?", min_update) if min_update.present?
    # contigs = contigs.where("updated_at <= ?", max_update) if max_update.present?

    contigs
  end
end
