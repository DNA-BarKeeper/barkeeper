class Primer < ActiveRecord::Base
  belongs_to :marker
  has_many :primer_reads
  has_many :primer_pos_on_genomes
  validates_presence_of :name

  def self.import(file)
    #spreadsheet = open_spreadsheet(file)

    spreadsheet = Roo::Excel.new(file, nil, :ignore)

    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]

      valid_keys = ['alt_name', 'sequence', 'author', 'name', 'tm', 'target_group'] #only direct attributes; associations are extra:

      # update existing spp or create new
      pri = find_by_name(row['name']) || new

      # add marker or assign to existing:
      fa = Marker.find_or_create_by(:name => row['marker'])

      #add orientation

      if row['reverse']=='R'
        pri.reverse=true
      else
        pri.reverse=false
      end

      pri.attributes = row.to_hash.slice(*valid_keys)
      pri.marker_id=fa.id
      pri.save!
    end
  end


end
