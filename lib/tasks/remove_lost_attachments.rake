#
# Barcode Workflow Manager - A web framework to assemble, analyze and manage DNA
# barcode data and metadata.
# Copyright (C) 2020 Kai Müller <kaimueller@uni-muenster.de>, Sarah Wiechers
# <sarah.wiechers@uni-muenster.de>
#
# This file is part of Barcode Workflow Manager.
#
# Barcode Workflow Manager is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# Barcode Workflow Manager is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with Barcode Workflow Manager.  If not, see
# <http://www.gnu.org/licenses/>.
#
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