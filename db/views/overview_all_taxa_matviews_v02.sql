SELECT
  f.name AS families,
  o.name AS orders,
  hot.name AS higher_order_taxa,
  size(f.species) AS species_cnt
FROM
  ((families f
INNER JOIN orders o ON f.order_id = o.id)
INNER JOIN higher_order_taxa hot ON o.higher_order_taxon_id = hot.id)