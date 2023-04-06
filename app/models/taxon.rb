#
# BarKeeper - A versatile web framework to assemble, analyze and manage DNA
# barcoding data and metadata.
# Copyright (C) 2022 Kai Müller <kaimueller@uni-muenster.de>, Sarah Wiechers
# <sarah.wiechers@uni-muenster.de>
#
# This file is part of BarKeeper.
#
# BarKeeper is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# BarKeeper is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with BarKeeper.  If not, see <http://www.gnu.org/licenses/>.
#
class Taxon < ApplicationRecord
  extend Import
  include ProjectRecord
  include PgSearch::Model

  has_many :individuals, dependent: :nullify
  has_many :ngs_runs, dependent: :nullify

  has_ancestry  cache_depth: true, counter_cache: true, orphan_strategy: :adopt

  validates_presence_of :scientific_name
  validates_uniqueness_of :scientific_name
  validates_presence_of :taxonomic_rank

  has_many_attached :voucher_images
  validates :voucher_images, limit: { min: 0, max: 5 }

  after_save :update_descendants_counter_cache
  after_destroy :update_descendants_counter_cache

  multisearchable against: [:scientific_name, :author, :comment, :common_name, :synonym]

  scope :orphans, -> { where(ancestry_depth: 0) }

  enum taxonomic_rank: %i[is_unranked is_division is_subdivision is_class is_order is_family is_genus is_species is_subspecies]

  def self.subtree_json(project_id, parent_id=nil, root_id=nil)
    if parent_id
      Taxon.find(parent_id).children.order(:position, :scientific_name)
           .in_project(project_id).arrange_serializable do |parent, children|
        { id: parent.id,
          scientific_name: parent.scientific_name,
          taxonomic_rank: parent.human_taxonomic_rank,
          common_name: parent.common_name,
          synonym: parent.synonym,
          author: parent.author,
          comment: parent.comment,
          has_children: parent.children_count.positive?,
          children: children}
      end.to_json
    else
      Taxon.find(root_id).subtree.to_depth(3).order(:position, :scientific_name)
           .in_project(project_id).arrange_serializable do |parent, children|
        { id: parent.id,
          scientific_name: parent.scientific_name,
          taxonomic_rank: parent.human_taxonomic_rank,
          common_name: parent.common_name,
          synonym: parent.synonym,
          author: parent.author,
          comment: parent.comment,
          has_children: parent.children_count.positive?,
          children: children}
      end.to_json
    end
  end

  def self.find_by_sci_name_or_synonym(identifier)
    taxon = Taxon.find_by_scientific_name(identifier)
    taxon ||= Taxon.find_by_synonym(identifier)
    taxon
  end

  def self.find_or_create_by_sci_name_or_synonym(identifier, **attributes)
    taxon = Taxon.find_by_sci_name_or_synonym(identifier)
    taxon ||= Taxon.create(scientific_name: identifier, attributes: attributes)
    taxon
  end

  def self.find_ancestry(taxon_name)
    Taxon.find_by_sci_name_or_synonym(taxon_name).try(:ancestry)
  end

  def self.to_csv(project_id)
    header = %w{ ID scientific_name synonym common_name taxonomic_rank author comment Parent_ID }
    attributes = %w{ id scientific_name synonym common_name human_taxonomic_rank author comment parent_id }

    CSV.generate(headers: true) do |csv|
      csv << header.map { |entry| entry.humanize }
      taxa = project_id ? in_project(project_id) : all

      taxa.each do |taxon|
        csv << attributes.map{ |attr| taxon.send(attr) }
      end
    end
  end

  def self.import_from_csv(file, project_id)
    spreadsheet = Taxon.open_spreadsheet(file)
    header = spreadsheet.row(1)
    cnt = 0

    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      id = row['ID']
      scientific_name = row['Scientific name']
      synonym = row['Synonym']
      taxonomic_rank = Taxon.taxonomic_ranks["is_" + row['Taxonomic rank'].downcase] if row['Taxonomic rank']
      taxonomic_rank ||= Taxon.taxonomic_ranks['is_unranked']

      if id && id.scan(/\D/).empty? # ID only consists of digits
        taxon = Taxon.find(id.to_i)
      elsif scientific_name
        taxon = Taxon.find_by_sci_name_or_synonym(scientific_name) if scientific_name
        taxon ||= Taxon.find_by_sci_name_or_synonym(synonym) if synonym
        taxon ||= Taxon.create(scientific_name: scientific_name, taxonomic_rank: taxonomic_rank)
      else
        break
      end

      common_name = row['Common name']
      author = row['Author']
      comment = row['Comment']

      parent_identifier = row['Parent']
      if parent_identifier.is_a?(Float)
        parent = Taxon.find(parent_identifier.to_i)
      else
        parent = Taxon.find_by_sci_name_or_synonym(parent_identifier)
        parent ||= Taxon.create(scientific_name: parent_identifier, taxonomic_rank: 'is_unranked')
        parent.save!
      end

      taxon.update(synonym: synonym, common_name: common_name, taxonomic_rank: taxonomic_rank, author: author,
                   comment: comment, parent: parent)
      taxon.add_project(project_id) if project_id
      taxon.save!
      cnt += 1
    end

    cnt
  end

  def update_descendants_counter_cache
    self.update_column(:descendants_count, self.descendants.where(taxonomic_rank: [:is_species, :is_subspecies]).size) if Taxon.exists?(id)
  end

  def parent_name
    parent.try(:scientific_name)
  end

  def parent_name=(scientific_name)
    if scientific_name == ''
      self.parent = nil
    else
      self.parent = Taxon.find_by(scientific_name: scientific_name) if scientific_name.present?
    end
  end

  def human_taxonomic_rank
    taxonomic_rank.split('_')[1].capitalize
  end

  def specimen_json
    Individual.where(taxon: self).to_json(only: [:id, :specimen_id])
  end
end
