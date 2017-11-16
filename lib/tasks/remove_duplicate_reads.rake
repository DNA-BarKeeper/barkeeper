require 'net/http'
require 'nokogiri'


namespace :data do

  desc "Remove duplicate reads not associated with a contig"
  task :remove_duplicate_reads => :environment do
    names_with_multiple = PrimerRead.select(:name).group(:name).having("count(name) > 1").count.keys
    delete = []

    names_with_multiple.first(100).each do | read_name |
      reads = PrimerRead.where("name like ?", read_name)
      reads.each {|read| puts read.name if read.contig_id.nil?}
      reads_wo_contig = reads.where(:contig_id => nil)

      if reads.size > reads_wo_contig.size && !reads_wo_contig.empty?
        puts reads.size
        puts reads_wo_contig.size
        # reads_wo_contig.each { |read| read.destroy! }
        delete.concat reads_wo_contig
      end
    end

    puts delete.size
    puts names_with_multiple.size
  end
end
