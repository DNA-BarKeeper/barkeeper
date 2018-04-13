require 'net/http'
require 'nokogiri'

def get_state(i)
  if i.locality

    regex = /^([A-Za-z0-9\-]+)\..+/

    matches = i.locality.match(regex)
    if matches
      state_component = matches[1]

      i.update(:state_province => state_component)
    end
  end
end

namespace :data do

  desc "Change precision of existing specimen location data records"
  task :change_location_data_precision => :environment do
    cnt = 0

    puts "Changing location data precision..."

    Individual.find_each(:batch_size => 50) do |individual|
      individual.update(:latitude => individual.latitude&.round(6))
      individual.update(:longitude => individual.longitude&.round(6))
      cnt += 1
    end

    puts "Done. Changed location data precision for #{cnt} records."
  end

  desc "Create users"
  task :create_users => :environment do
    @user = User.new(:name => 'Tim Boehnert', :email => 'tim.boehnert@uni-bonn.de', :password => 'HMeWE98qRp3f', :password_confirmation => 'HMeWE98qRp3f')
    @user.save

    @user2 = User.new(:name => 'Saskia Schlesak', :email => 'saskia.schlesak@googlemail.com', :password => 'tJ6knF6q3DZX', :password_confirmation => 'tJ6knF6q3DZX')
    @user2.save

    @user3 = User.new(:name => 'Gabriele Droege', :email => 'G.Droege@bgbm.org', :password => 'T3HqXUd4zVA2', :password_confirmation => 'T3HqXUd4zVA2')
    @user3.save

    puts "Done."
  end

  desc "destroy duplicate reads from non-verified contigs"
  task :destroy_duplicate_reads => :environment do
    # get list w duplicate reads FROM NON-VERIFIED CONTIGS ONLY
    a = []

    PrimerRead.select("name").contig_not_verified.each do |i|
      a << i.name
    end

    d = a.select{ |e| a.count(e) > 1 }.uniq

    # Iterate over duplicate read names:
    d.each do |duplicate|
      # Get  all members of given duplicate list: # IGNORE THOSE FROM VERIFIED CONTIGS IN THIS DUPLICATE LIST
      dups = PrimerRead.contig_not_verified.where(:name => duplicate)

      # Get first
      first_dup=dups.first

      # puts "will keep #{first_dup.name} (#{first_dup.id})"

      # Get all others

      #TODO: scary loop in which arr.elements are deleted (?) - fix!

      (1..dups.count-1).each do |i|

        curr_dup= dups[i]

        # puts "will destroy #{curr_dup.name} (#{curr_dup.id})"

        curr_dup.destroy
      end

      puts "\n"
    end

    puts 'Done.'
  end

  desc "fix empty state-province from DNABank- import"
  task :fix_state_province => :environment do
    Individual.where(:state_province => nil).each do |i|
      get_state(i)
    end

    Individual.where(:state_province => "").each do |i|
      get_state(i)
    end
  end

  #TODO: scary loop in which arr.elements are deleted - fix!

  desc "Merge multiple copies of same contigs into one with all associations & attributes"
  task :merge_duplicate_contigs => :environment do
    # get list w duplicates
    a=[]
    Contig.select("name").each do |i|
      a << i.name
    end
    d=a.select{ |e| a.count(e) > 1 }.uniq

    # iterate over duplicate lab_nrs:
    d.each do |duplicate|

      #get  all members of given duplicate list:
      dups=Contig.where(:name => duplicate).where(:verified_by => nil)

      if dups.count > 1

        #get first
        first_dup=dups.first

        #get all others and compare to first
        (1..dups.count-1).each do |i|
          curr_dup= dups[i]

          puts "#{curr_dup.name} (#{curr_dup.id})  vs #{first_dup.name} ( #{first_dup.id} ):"

          if curr_dup.isolate
            first_dup.update(:isolate => curr_dup.isolate)
          end

          if curr_dup.marker
            first_dup.update(:marker => curr_dup.marker)
          end

          if curr_dup.marker_sequence
            first_dup.update(:marker_sequence => curr_dup.marker_sequence)
          end

          if curr_dup.partial_cons.count > 0
            curr_dup.partial_cons.each do |m|
              first_dup.partial_cons << m
            end
          end

          if curr_dup.primer_reads.count >0
            curr_dup.primer_reads.each do |c|
              first_dup.primer_reads << c
            end
          end

          curr_dup.destroy

        end
      end

      puts ""
    end

    puts "Done."

  end

  #TODO: scary loop in which arr.elements are deleted - fix!
  desc "Merge multiple copies of same isolate into one with all associations & attributes"
  task :merge_duplicate_isolates => :environment do

    # get list w duplicates
    a=[]
    Isolate.select("lab_nr").all.each do |i|
      a << i.lab_nr
    end
    d=a.select{ |e| a.count(e) > 1 }.uniq


    # iterate over duplicate lab_nrs:
    d.each do |duplicate_isolate|

      #get  all members of given duplicate list:
      dups=Isolate.includes(:individual => :species).where(:lab_nr => duplicate_isolate)

      #get first
      first_dup=dups.first

      #get all others and compare to first
      (1..dups.count-1).each do |i|
        curr_dup= dups[i]
        puts "#{curr_dup.lab_nr} (#{curr_dup.id})  vs #{first_dup.lab_nr} ( #{first_dup.id} ):"

        if curr_dup.individual
          first_dup.update(:individual => curr_dup.individual)
        end

        if curr_dup.marker_sequences.count > 0
          curr_dup.marker_sequences.each do |m|
            first_dup.marker_sequences << m
          end
        end

        if curr_dup.contigs.count >0
          curr_dup.contigs.each do |c|
            first_dup.contigs << c
          end
        end

        curr_dup.destroy

      end

      puts ""
    end

    puts "Done."

  end

  desc 'Remove duplicate reads not associated with a contig'
  task :remove_duplicate_reads_without_contig => :environment do
    puts 'Deleting duplicate primer reads not associated with a contig if one of the pair/group is associated with a contig...'

    names_with_multiple = PrimerRead.select(:name).group(:name).having("count(name) > 1").count.keys
    primer_reads_cnt = PrimerRead.where(name: names_with_multiple).count
    delete_cnt = 0

    puts "#{primer_reads_cnt} duplicate reads were found."

    names_with_multiple.each do | read_name |
      duplicates = PrimerRead.where(:name => read_name)
      reads_wo_contig = []
      duplicates.each {|d| reads_wo_contig << d if !d.contig }

      if duplicates.size > reads_wo_contig.size && !reads_wo_contig.empty?
        reads_wo_contig.each do |read|
          delete_cnt += 1
          read.destroy!
        end
      end
    end

    puts "#{delete_cnt} duplicate reads could be deleted."
  end

  desc 'Remove older ones of a group of duplicate reads'
  task :delete_older_duplicate_reads => :environment do
    puts 'Deleting the older primer reads of a group of duplicates...'

    names_with_multiple = PrimerRead.select(:name).group(:name).having("count(name) > 1").count.keys
    primer_reads_cnt = PrimerRead.where(name: names_with_multiple).count
    delete_cnt = 0

    puts "#{primer_reads_cnt} duplicate reads were found."

    names_with_multiple.each do | read_name |
      if read_name.match('\AF') # Only treat reads starting with an 'F'
        duplicates = PrimerRead.where(:name => read_name).order(created_at: :desc)

        # Delete all older reads, keep only newest one
        duplicates[1..-1].each do |r|
          r.destroy!
          delete_cnt += 1
        end
      end
    end

    puts "#{delete_cnt} duplicate reads could be deleted."
  end


end