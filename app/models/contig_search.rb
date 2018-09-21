class ContigSearch < ApplicationRecord
  include Export

  belongs_to :user
  belongs_to :project

  enum has_warnings: [:both, :yes, :no]

  # TODO: Unfinished feature
  # has_attached_file :search_result_archive,
  #                   :path => ":rails_root/contig_search_results/:filename"
  #
  # # Validate content type
  # validates_attachment_content_type :search_result_archive, :content_type => /\Aapplication\/zip/
  #
  # # Validate filename
  # validates_attachment_file_name :search_result_archive, :matches => [/zip\Z/]

  def contigs
    @contigs ||= find_contigs
  end

  private

  def find_contigs
    contigs = Contig.in_project(user.default_project_id).order(:name)
    contigs = contigs.where("contigs.name ilike ?", "%#{name}%") if name.present?

    if assembled != 'both'
      contigs = contigs.assembled if (assembled == 'assembled')
      contigs = contigs.not_assembled if (assembled == 'unassembled')
    end

    if verified != 'both'
      contigs = contigs.verified if (verified == 'verified')
      contigs = contigs.where(verified: false) if (verified == 'unverified')
    end

    if has_warnings != 'both'
      contigs = contigs.with_warnings if (has_warnings == 'yes')
      contigs = contigs.where.not(id: Contig.with_warnings.pluck(:id)) if (has_warnings == 'no')
    end

    contigs = contigs.joins(:marker).where("markers.name ilike ?", "%#{marker}%") if marker.present?

    contigs = contigs.joins(isolate: { individual: {species: {family: :order}}}).where("orders.name ilike ?", "%#{order}%") if order.present?

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
