class ResetAllTaxaCacheCounters < ActiveRecord::Migration[5.2]
  def up
    Taxon.all.each do |taxon|
      taxon.update(children_count: taxon.children.size)
    end
  end

  def down
    # no rollback needed
  end
end
