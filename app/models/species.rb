class Species < ActiveRecord::Base
  has_many :individuals
  has_many :primer_pos_on_genomes
  belongs_to :family

  def filter
    @species = Species.where('composed_name ILIKE ?', "%#{params[:term]}%").order(:name)
  end

  def self.in_higher_order_taxon(higher_order_taxon_id)
    count=0
    HigherOrderTaxon.find(higher_order_taxon_id).orders.each do |ord|
      ord.families.each do |fam|
        count+=fam.species.count
      end
    end
    count
  end

  # version for Stuttgart

  # def self.import(file)
  #   #spreadsheet = open_spreadsheet(file)
  #
  #   spreadsheet = Roo::Excel.new(file, nil, :ignore)
  #
  #   header = spreadsheet.row(1)
  #   (2..spreadsheet.last_row).each do |i|
  #     row = Hash[[header, spreadsheet.row(i)].transpose]
  #
  #     valid_keys = ['genus_name',
  #                   'species_epithet',
  #                   'id',
  #                   'author',
  #                   'infraspecific',
  #                   'commment',
  #                   'german_name'] #only direct attributes; associations are extra:
  #
  #     # update existing spp or create new
  #     sp = find_by_id(row['id']) || new
  #
  #     # add family or assign to existing:
  #     fa = Family.find_or_create_by(:name => row['family'])
  #
  #     # add order or assign to existing:
  #     ord = Order.find_or_create_by(:name => row['order'])
  #     fa.update(:order_id => ord.id)
  #
  #     # add higher-order or assign to existing:
  #     hot = HigherOrderTaxon.find_or_create_by(:name => row['higher_order_taxon'])
  #     ord.update(:higher_order_taxon_id => hot.id)
  #
  #     sp.attributes = row.to_hash.slice(*valid_keys)
  #     sp.family_id=fa.id
  #     sp.composed_name=sp.full_name
  #     sp.save!
  #
  #     if sp.genus_name.nil?
  #       components=[]
  #       components=sp.composed_name.split(' ')
  #       sp.update(:genus_name => components.first)
  #
  #       if components.size = 3
  #         if components[1] == 'x'
  #           species_ep=components[1] + ' ' + components.last
  #           sp.update(:species_epithet => species_ep)
  #         else
  #           sp.update(:species_epithet => components[1], :infraspecific => components.last)
  #         end
  #       end
  #     end
  #
  #   end
  # end



  def self.import(file)
    #version for Berlin


    spreadsheet = Roo::Excel.new(file, nil, :ignore)

    header = spreadsheet.row(1)
    (3..spreadsheet.last_row).each do |i| #3 because of complicated header line in Ralfs excel
      row = Hash[[header, spreadsheet.row(i)].transpose]

      valid_keys = ['genus_name','species_epithet','id','author','infraspecific','author_infra','commment'] #only direct attributes; associations are extra:

      # update existing spp or create new
      sp = find_by_id(row['id']) || new

      # add family or assign to existing:
      fa = Family.find_or_create_by(:name => row['family'])

      # add order or assign to existing:
      ord = Order.find_or_create_by(:name => row['order'])
      fa.update(:order_id => ord.id)

      # add order or assign to existing:
      hot = HigherOrderTaxon.find_or_create_by(:name => 'Magnoliopsida')
      ord.update(:higher_order_taxon_id => hot.id)

      sp.attributes = row.to_hash.slice(*valid_keys)
      sp.family_id=fa.id
      sp.save
      sp.update(:composed_name=>sp.full_name)

      # if sp.genus_name.nil?
      #   components=[]
      #   components=sp.composed_name.split(' ')
      #   sp.update(:genus_name => components.first)
      #
      #   if components.size = 3
      #     if components[1] == 'x'
      #       species_ep=components[1] + ' ' + components.last
      #       sp.update(:species_epithet => species_ep)
      #     else
      #       sp.update(:species_epithet => components[1], :infraspecific => components.last)
      #     end
      #   end
      # end

    end
  end

  def self.open_spreadsheet(file)
    case File.extname(file.original_filename)
      when '.csv' then Roo::Csv.new(file.path)
      when '.xls' then Roo::Excel.new(file.path, nil, :ignore)
      when '.xlsx' then Roo::Excelx.new(file.path, nil, :ignore)
      else raise "Unknown file type: #{file.original_filename}"
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
      "#{self.genus_name} #{self.species_epithet} ssp. #{self.infraspecific}".strip
    end
  end

  def family_name
    family.try(:name)
  end

  def family_name=(name)
    self.family = Family.find_or_create_by(:name => name) if name.present?
  end

end
