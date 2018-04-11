SELECT
  f.name AS family,
  o.name AS tax_order,
  hot.name AS higher_order_taxon,
  f.*,
  COUNT(sp.family_id) AS species_cnt
FROM ((families f
  INNER JOIN orders o ON f.order_id = o.id)
  INNER JOIN higher_order_taxa hot ON o.higher_order_taxon_id = hot.id)
  LEFT OUTER JOIN species sp
    ON f.id = sp.family_id
  GROUP BY f.id, f.name, o.name, hot.name
