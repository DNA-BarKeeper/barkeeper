namespace :data do

  task :run_python => :environment do
    file = Rails.root.join('lib', 'sativa_test_files', 'python_test.py')
    output = `python #{file}`
    puts output
  end

  desc "Runs a SATIVA mislabel analysis"
  task :run_sativa => :environment do
    # SATIVA only understands relative file paths and has to be called inside the directory with the analysis data
    analysis_dir = Rails.root.join('lib', 'sativa_test_files')
    alignment_file = 'gbol5_caryophyllales_ITS_aligned.fasta'
    tax_file = 'gbol5_caryophyllales_ITS.tax'

    Dir.chdir(analysis_dir) do
      `python /home/sarah/SATIVA/sativa/sativa.py -s #{alignment_file} -t #{tax_file} -x BOT`
    end
  end

end