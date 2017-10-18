class CreateTaxaMatview < ActiveRecord::Migration[5.0]
  def up
    execute <<-SQL
      CREATE MATERIALIZED VIEW taxa_matview AS
        SELECT
          f.name AS family,
          o.name AS order,
          hot.name AS higher_order_taxon
        FROM
          ((families f
        INNER JOIN orders o ON f.order_id = o.id)
        INNER JOIN higher_order_taxa hot ON o.higher_order_taxon_id = hot.id)
    SQL
  end

  def down
    execute <<-SQL
      DROP MATERIALIZED VIEW IF EXISTS taxa_matview;
    SQL
  end
end
