-- 
-- Barcode Workflow Manager - A web framework to assemble, analyze and manage DNA
-- barcode data and metadata.
-- Copyright (C) 2020 Kai Müller <kaimueller@uni-muenster.de>, Sarah Wiechers
-- <sarah.wiechers@uni-muenster.de>
--
-- This file is part of Barcode Workflow Manager.
--
-- Barcode Workflow Manager is free software: you can redistribute it and/or modify
-- it under the terms of the GNU Affero General Public License as
-- published by the Free Software Foundation, either version 3 of the
-- License, or (at your option) any later version.
--
-- Barcode Workflow Manager is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU Affero General Public License for more details.
--
-- You should have received a copy of the GNU Affero General Public License
-- along with Barcode Workflow Manager.  If not, see
-- <http://www.gnu.org/licenses/>.
-- 
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