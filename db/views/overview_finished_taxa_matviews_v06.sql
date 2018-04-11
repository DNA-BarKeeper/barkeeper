SELECT
  COUNT(CASE WHEN "marker_sequences"."marker_id" = 4 THEN 1 END) AS trnLF_cnt,
  COUNT(CASE WHEN "marker_sequences"."marker_id" = 5 THEN 1 END) AS ITS_cnt,
  COUNT(CASE WHEN "marker_sequences"."marker_id" = 6 THEN 1 END) AS rpl16_cnt,
  COUNT(CASE WHEN "marker_sequences"."marker_id" = 7 THEN 1 END) AS trnK_matK_cnt,
  families.name AS families_name
FROM "marker_sequences"
  INNER JOIN "isolates" ON "isolates"."id" = "marker_sequences"."isolate_id"
  INNER JOIN "individuals" ON "individuals"."id" = "isolates"."individual_id"
  INNER JOIN "species" ON "species"."id" = "individuals"."species_id"
  INNER JOIN "families" ON "families"."id" = "species"."family_id"
GROUP BY families.name
ORDER BY families.name

-- MarkerSequence.joins(isolate: [individual: [species: :family]]).where(:marker => 5).order('families.name').group('families.name').count