namespace :migrate_paperclip do
  desc 'Remove paperclip attachments if no file can be found on the server'
  task remove_attachments: :environment do
    Rails.application.eager_load!

    models = ActiveRecord::Base.descendants.reject(&:abstract_class?)

    models.each do |model|
      puts 'Checking Model [' + model.to_s + '] for Paperclip attachment columns ...'

      attachments = model.column_names.map do |c|
        Regexp.last_match(1) if c =~ /(.+)_file_name$/
      end.compact

      if attachments.blank?
        puts '  No Paperclip attachment columns found for [' + model.to_s + '].'
        puts ''
        next
      end

      puts '  Paperclip attachment columns found for [' + model.to_s + ']: ' + attachments.to_s

      cnt = 0
      model.find_each.each do |instance|
        attachments.each do |attachment|
          next if instance.send(attachment).path.blank?

          if instance.send(attachment).url.include?('missing.png')
            # attachment.destroy
            cnt += 1
          end
        end
      end

      puts "#{cnt} attachments were destroyed for model #{model.to_s}."
      puts ''
    end
  end
end