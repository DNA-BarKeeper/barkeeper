namespace :data do

  desc "get_aligned_peak_indices"

  task :get_aligned_peak_indices => :environment do

    total= PrimerRead.use_for_assembly.where(:aligned_peak_indices => nil).count

    ctr=0
    PrimerRead.use_for_assembly.where( :aligned_peak_indices => nil).select(:id, :trimmedReadStart, :aligned_qualities, :aligned_peak_indices, :peak_indices).find_in_batches(batch_size: 100) do |batch|
      batch.each do |pr|
        ctr+=1
        puts "#{ctr} / #{total}"
        pr.get_aligned_peak_indices
      end
    end

    puts "Done."

  end

end