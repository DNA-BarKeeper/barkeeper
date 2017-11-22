namespace :data do

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
