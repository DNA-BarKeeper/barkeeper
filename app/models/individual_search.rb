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

# frozen_string_literal: true

class IndividualSearch < ApplicationRecord
  belongs_to :user
  belongs_to :project

  validates :title, uniqueness: { :allow_blank => true,
                                  :scope=> :user_id }

  enum has_issue: %i[all_issue issues no_issues]
  enum has_taxon: %i[all_taxon taxon no_taxon]
  enum has_problematic_location: %i[all_location bad_location location_okay]

  def individuals
    @individuals ||= find_individuals
  end

  def to_csv
    header = %w{ Database_ID specimen_id taxon_name determination collection collectors_field_number collector collection_date
state_province country latitude longitude elevation exposition locality habitat comments }

    attributes = %w{ id specimen_id taxon_name determination collection_name collectors_field_number collector collected
state_province country latitude longitude elevation exposition locality habitat comments }

    CSV.generate(headers: true) do |csv|
      csv << header.map { |entry| entry.humanize }

      individuals.includes(:taxon).each do |individual|
        csv << attributes.map{ |attr| individual.send(attr) }
      end
    end
  end

  private

  def find_individuals
    individuals = Individual.in_project(project_id).order(:specimen_id)

    individuals = individuals.where('individuals.specimen_id ilike ?', "%#{specimen_id}%") if specimen_id.present?

    individuals = individuals.where('individuals.DNA_bank_id ilike ?', "%#{self.DNA_bank_id}%") if self.DNA_bank_id.present?

    if has_problematic_location != 'all_location'
      individuals = individuals.bad_location if has_problematic_location == 'bad_location'
      individuals = individuals.where.not(id: Individual.bad_location.pluck(:id)) if has_problematic_location == 'location_okay'
    end

    if has_issue != 'all_issue'
      individuals = individuals.where(has_issue: true) if has_issue == 'issues'
      individuals = individuals.where(has_issue: nil).or(individuals.where(has_issue: false)) if has_issue == 'no_issues'
    end

    if has_taxon != 'all_taxon'
      individuals = individuals.joins(:taxon) if has_taxon == 'taxon'
      individuals = individuals.without_taxon if has_taxon == 'no_taxon'
    end

    individuals = individuals.joins(:collection).where('collections.name ilike ?', "%#{collection}%") if collection.present?

    individuals = individuals.joins(:taxon).where('taxa.scientific_name ilike ?', "%#{taxon}%") if taxon.present?

    individuals
  end
end
