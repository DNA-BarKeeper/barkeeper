namespace :data do
  desc 'get information about marker sequences in database'

  task :sequence_info => :environment do
    marker_sequences = MarkerSequence.all
    sequence_count = {}

    Marker.all.each do |marker|
      sequence_count[marker.name] = marker_sequences.where(marker_id: marker.id)
    end
    # - anzahl marker sequenzen (pro hot und pro marker)
    # - durchschnittliche länge (pro marker)
    # - minimale und maximale länge
    # - anzahl sequenzen ohne contig
    # - anzahl sequenzen ohne taxonomic info (probably the same)
    # - anzahl specimen
    # - durchschnittliche anzahl von reads per contig (pro marker)
  end
end