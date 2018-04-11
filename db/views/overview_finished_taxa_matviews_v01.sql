SELECT
  f.name AS family,
  COUNT(spe.family_id) AS all_species_cnt,
  COUNT(CASE WHEN mseq.marker_ID = 4 THEN 1 END) AS trnLF_cnt,
  COUNT(CASE WHEN mseq.marker_ID = 5 THEN 1 END) AS ITS_cnt,
  COUNT(CASE WHEN mseq.marker_ID = 6 THEN 1 END) AS rpl16_cnt,
  COUNT(CASE WHEN mseq.marker_ID = 7 THEN 1 END) AS trnK_matK_cnt
FROM ((((families f
  LEFT OUTER JOIN species spe ON f.id = spe.family_id)
  LEFT OUTER JOIN individuals ind ON spe.id = ind.species_id)
  LEFT OUTER JOIN isolates iso ON ind.id = iso.individual_id)
  LEFT OUTER JOIN marker_sequences mseq ON iso.id = mseq.isolate_id)
GROUP BY f.id, f.name