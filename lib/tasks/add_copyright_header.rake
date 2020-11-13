namespace :copyright do
  require 'rubygems'
  require 'copyright_header'

  task headers: :environment do
    args = {
        :license => 'AGPL3',
        :copyright_software => 'Barcode Workflow Manager',
        :copyright_software_description => "A web framework to assemble, analyze and manage DNA barcode data and metadata.",
        :copyright_holders => ['Kai Müller <kaimueller@uni-muenster.de>', 'Sarah Wiechers <sarah.wiechers@uni-muenster.de>'],
        :copyright_years => ['2020'],
        :add_path => 'app:db:docker:lib:spec',
        :output_dir => '.'
    }

    execute_copyright_headers(args)
  end

  task headers_dry_run: :environment do
    args = {
        :license => 'AGPL3',
        :copyright_software => 'Barcode Workflow Manager',
        :copyright_software_description => "A web framework to assemble, analyze and manage DNA barcode data and metadata.",
        :copyright_holders => ['Kai Müller <kaimueller@uni-muenster.de>', 'Sarah Wiechers <sarah.wiechers@uni-muenster.de>'],
        :copyright_years => ['2020'],
        :add_path => 'app:db:docker:lib/tasks:spec',
        :output_dir => '/tmp',
        :dry_run => true
    }

    execute_copyright_headers(args)
  end

  private

  def execute_copyright_headers(args)
    command_line = CopyrightHeader::CommandLine.new(args)
    command_line.execute
  end
end
