namespace :data do
  desc "fill reads' basecount"

  task :base_counts => :environment do

    PrimerRead.where(:base_count => nil).find_each do |p|
      if p.sequence
        p.update(:base_count => p.sequence.length)
        puts p.name
      end
    end

    puts "Done."

  end

end