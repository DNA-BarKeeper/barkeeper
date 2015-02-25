class Individual < ActiveRecord::Base
  has_many :isolates
  belongs_to :species

  def self.to_csv(options = {})

    # change to_csv block to list attributes/values individually
    CSV.generate(options) do |csv|
      csv << column_names
      all.each do |individual|
        csv << individual.attributes.values_at(*column_names)
      end
    end
  end

  def self.export(file)

    # GBOL-Nr.
    # Feldnummer
    # Institut
    # Sammlungs-Nr.
    # Familie
    # Taxon-Name
    # Erstbeschreiber Jahr
    # evtl. Bemerkung Taxonomie
    # Name
    # Datum
    # Gewebetyp und Menge
    # Anzahl Individuen
    # Fixierungsmethode
    # Entwicklungsstadium
    # Sex
    # evtl. Bemerkungen zur Probe
    # Fundortbeschreibung
    # Region
    # Bundesland
    # Land
    # Datum
    # Sammelmethode
    # Breitengrad
    # Längengrad
    # Benutzte Methode
    # Ungenauigkeitsangabe
    # Höhe/Tiefe [m]
    # Habitat
    # Sammler
    # Nummer
    # Behörde

  end

  def self.spp_in_higher_order_taxon(higher_order_taxon_id)
    individuals= Individual.select("species_id").joins(:species => {:family => {:order => :higher_order_taxon}}).where(orders: {higher_order_taxon_id: higher_order_taxon_id})
    [individuals.count, individuals.uniq.count]
  end

  def species_name
    species.try(:composed_name)
  end

  def species_name=(name)
    if name == ''
      self.species = nil
    else
      self.species = Species.find_or_create_by(:composed_name => name) if name.present?
    end
  end

  def habitat_for_display
    if self.habitat.present? and self.habitat.length > 60
      "#{self.habitat[0..30]...self.habitat[-30..-1]}"
    else
      self.habitat
    end
  end

  def locality_for_display
    if self.locality.present? and self.locality.length > 60
      "#{self.locality[0..30]...self.locality[-30..-1]}"
    else
      self.locality
    end
  end

  def comments_for_display
    if self.comments.present? and self.comments.length > 60
      "#{self.comments[0..30]...self.comments[-30..-1]}"
    else
      self.comments
    end
  end

end
