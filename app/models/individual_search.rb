# frozen_string_literal: true

class IndividualSearch < ApplicationRecord
  belongs_to :user
  belongs_to :project

  enum has_issue: %i[all_issue issues no_issues]
  enum has_species: %i[all_species species no_species]
  enum has_problematic_location: %i[all_location bad_location location_okay]

  def individuals
    @individuals ||= find_individuals
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

    if has_species != 'all_species'
      individuals = individuals.joins(:species) if has_species == 'species'
      individuals = individuals.without_species if has_species == 'no_species'
    end

    individuals = individuals.joins(:herbarium).where('herbaria.acronym ilike ?', "%#{herbarium}%") if herbarium.present?

    individuals = individuals.joins(species: { family: :order }).where('orders.name ilike ?', "%#{self.order}%") if order.present?

    individuals = individuals.joins(species: :family).where('families.name ilike ?', "%#{family}%") if family.present?

    individuals = individuals.joins(:species).where('species.composed_name ilike ?', "%#{species}%") if species.present?

    individuals
  end
end
