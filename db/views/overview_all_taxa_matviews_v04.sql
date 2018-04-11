SELECT
  f.name AS family,
  COUNT(sp.family_id) AS species_cnt
FROM families f
  LEFT OUTER JOIN species sp ON f.id = sp.family_id
  GROUP BY f.id, f.name

-- Family.joins(:species).select('family.name AS family_name').group(:name).order(:name).count(:species)
-- SELECT
--   COUNT(species) AS count_species,
--   "families"."name" AS families_name
-- FROM "families"
--   INNER JOIN "species" ON "species"."family_id" = "families"."id"
--   GROUP BY "families"."name"
--   ORDER BY "families"."name" ASC

-- Species.joins(:family).order('families.name').group('families.name').count
-- SELECT
--   COUNT(*) AS count_all,
--   families.name AS families_name
-- FROM "species"
--   INNER JOIN "families" ON "families"."id" = "species"."family_id"
--   GROUP BY families.name
--   ORDER BY families.name