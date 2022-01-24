/*
 * BarKeeper - A versatile web framework to assemble, analyze and manage DNA
 * barcoding data and metadata.
 * Copyright (C) 2022 Kai Müller <kaimueller@uni-muenster.de>, Sarah Wiechers
 * <sarah.wiechers@uni-muenster.de>
 *
 * This file is part of BarKeeper.
 *
 * BarKeeper is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * BarKeeper is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with BarKeeper.  If not, see <http://www.gnu.org/licenses/>.
 */

jQuery(function() {
    $('#marker_sequence_search_min_age').datepicker({
        dateFormat: 'yy-mm-dd'
    });

    $('#marker_sequence_search_max_age').datepicker({
        dateFormat: 'yy-mm-dd'
    });

    $('#marker_sequence_search_min_update').datepicker({
        dateFormat: 'yy-mm-dd'
    });

    $('#marker_sequence_search_max_update').datepicker({
        dateFormat: 'yy-mm-dd'
    });
});