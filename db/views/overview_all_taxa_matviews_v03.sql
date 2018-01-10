SELECT
  f.name AS family,
  f.*,
  COUNT(sp.family_id) AS species_cnt
FROM families f
  LEFT OUTER JOIN species sp ON f.id = sp.family_id
  GROUP BY f.id, f.name