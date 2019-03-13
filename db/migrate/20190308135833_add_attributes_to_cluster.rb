class AddAttributesToCluster < ActiveRecord::Migration[5.0]
  def change
    add_column :clusters, :sequence_count, :integer
    add_column :clusters, :fasta, :string
    add_column :clusters, :reverse_complement, :boolean

    add_reference :clusters, :isolate, index: true
    add_reference :clusters, :ngs_run, index: true
    add_reference :clusters, :marker, index: true

    add_reference :ngs_runs, :isolate, index: true
  end
end
