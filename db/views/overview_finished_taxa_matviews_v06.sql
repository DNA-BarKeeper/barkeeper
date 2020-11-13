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