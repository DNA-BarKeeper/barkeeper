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
  f.*,
  COUNT(sp.family_id) AS species_cnt
FROM families f
  LEFT OUTER JOIN species sp ON f.id = sp.family_id
  GROUP BY f.id, f.name