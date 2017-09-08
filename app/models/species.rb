class Species < ActiveRecord::Base
  has_many :individuals
  has_many :primer_pos_on_genomes
  belongs_to :family
  has_and_belongs_to_many :projects


  def filter
    @species = Species.where('composed_name ILIKE ?', "%#{params[:term]}%").order(:name)
  end


  def self.spp_in_higher_order_taxon(higher_order_taxon_id)
    spp=Species.select("species_component").joins(:family => {:order => :higher_order_taxon}).where(orders: {higher_order_taxon_id: higher_order_taxon_id})
    subspp=Species.select("id").joins(:family => {:order => :higher_order_taxon}).where(orders: {higher_order_taxon_id: higher_order_taxon_id})
    [spp.uniq.count, subspp.count]
  end


  # def self.spp_in_higher_order_taxon(higher_order_taxon_id)
  #   contigs=Contig.select("species_id").includes(:isolate => :individual).joins(:isolate => {:individual => {:species => {:family => {:order => :higher_order_taxon}}}}).where(orders: {higher_order_taxon_id: higher_order_taxon_id})
  #   contigs_i=Contig.select("individual_id").includes(:isolate => :individual).joins(:isolate => {:individual => {:species => {:family => {:order => :higher_order_taxon}}}}).where(orders: {higher_order_taxon_id: higher_order_taxon_id})
  #
  #   [contigs.count, contigs.uniq.count, contigs_i.uniq.count]
  # end


  def self.open_spreadsheet(file)
    case File.extname(file.original_filename)
      when '.csv' then Roo::Csv.new(file.path)
      when '.xls' then Roo::Excel.new(file.path)
      when '.xlsx' then Roo::Excelx.new(file.path)
      else raise "Unknown file type: #{file.original_filename}"
    end
  end


  def self.import_gbolII(file)
    spreadsheet = open_spreadsheet(file)
    header = spreadsheet.row(1)

    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]

      if (row['GBOL 1 oder 2?'].include? 'GBOL2') || (row['GBOL 1 oder 2?'].include? 'Nachtrag') # Only add new species
        # Add family or assign to existing:
        family = Family.find_or_create_by(:name => row['Familie (sensu APG)'])

        # Add order or assign to existing
        order = Order.find_or_create_by(:name => row['Ordnung (sensu APG)'])
        family.update(:order_id => order.id)

        full_name = row['Arten/Unterarten']
        components = full_name.split(' ')

        species = Species.find_or_create_by(:composed_name => full_name)

        species.update(:family => family)
        species.update(:genus_name => components.first)

        if components.size == 3
          if components[1] == 'x'
            species_ep = components[1] + ' ' + components.last
            species.update(:species_epithet => species_ep)
          else
            species.update(:species_epithet => components[1], :infraspecific => components.last)
          end
        else
          species.update(:species_epithet => components[1])
        end

        species.update(:species_component => species.get_species_component)
      end
    end
  end


  def self.import(file, valid_keys)
    spreadsheet = open_spreadsheet(file)
    header = spreadsheet.row(1)

    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]

      # Add family or assign to existing:
      family = Family.find_or_create_by(:name => row['family'])

      # Add order or assign to existing
      order = Order.find_or_create_by(:name => row['order'])
      family.update(:order_id => order.id)

      # Add higher-order taxon or assign to existing if info is available
      higher_order_taxon = HigherOrderTaxon.find_or_create_by(:name => row['higher_order_taxon'])
      order.update(:higher_order_taxon_id => higher_order_taxon.id)

      # Update existing species or create new
      species = find_by_id(row['id']) || new

      species.attributes = row.to_hash.slice(*valid_keys)
      species.family_id = family.id

      unless row['variety'].nil?
        species.infraspecific = row['variety']
        if species.comment
          species.comment += '- is a variety'
        else
          species.comment = '- is a variety'
        end
      end

      species.composed_name = species.full_name
      species.species_component = species.get_species_component

      species.save!
    end
  end


  def self.import_Stuttgart(file)
    valid_keys = %w('genus_name',
                  'species_epithet',
                  'id',
                  'author',
                  'author_infra',
                  'infraspecific',
                  'comment',
                  'german_name') # Only direct attributes; associations are extra

    self.import(file, valid_keys)
  end


  def self.import_Berlin(file)
    valid_keys = %w('genus_name',
                    'species_epithet',
                    'id',
                    'author',
                    'infraspecific',
                    'author_infra',
                    'comment') # Only direct attributes; associations are extra

    self.import(file, valid_keys)
  end


  def self.import_Stuttgart_set_class(file)
    spreadsheet = open_spreadsheet(file)

    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|

      row = Hash[[header, spreadsheet.row(i)].transpose]

      order = Order.find_by_name(row['order'])

      if order
        taxonomic_class = TaxonomicClass.find_or_create_by(:name => row['class'])

        if taxonomic_class
          order.update(:taxonomic_class_id => taxonomic_class.id)
          subdivision= Subdivision.find_or_create_by(:name => row['subdivision'])

          if subdivision
            taxonomic_class.update(:subdivision_id => subdivision.id)
          end
        end
      end

    end
  end


  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << column_names
      all.each do |sp|
        csv << sp.attributes.values_at(*column_names)
        #todo: associations are missing this way.
      end
    end
  end


  def full_name
    "#{self.genus_name} #{self.species_epithet} #{self.infraspecific}".strip
  end


  def name_for_display
    if self.infraspecific.nil? or self.infraspecific.blank?
      "#{self.genus_name} #{self.species_epithet}".strip
    else
      if self.comment and self.comment.include? "- is a variety"
        "#{self.genus_name} #{self.species_epithet} var. #{self.infraspecific}".strip
      else
        "#{self.genus_name} #{self.species_epithet} ssp. #{self.infraspecific}".strip
      end
    end
  end


  def get_species_component
    "#{self.genus_name} #{self.species_epithet}".strip
  end


  def family_name
    family.try(:name)
  end


  def family_name=(name)
    self.family = Family.find_or_create_by(:name => name) if name.present?
  end
end
