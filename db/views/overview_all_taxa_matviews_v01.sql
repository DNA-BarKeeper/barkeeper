SELECT
  f.name AS family,
  o.name AS order,
  hot.name AS higher_order_taxon
FROM
  ((families f
INNER JOIN orders o ON f.order_id = o.id)
INNER JOIN higher_order_taxa hot ON o.higher_order_taxon_id = hot.id)