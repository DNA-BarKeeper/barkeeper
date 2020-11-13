/*
 * Barcode Workflow Manager - A web framework to assemble, analyze and manage DNA
 * barcode data and metadata.
 * Copyright (C) 2020 Kai Müller <kaimueller@uni-muenster.de>, Sarah Wiechers
 * <sarah.wiechers@uni-muenster.de>
 *
 * This file is part of Barcode Workflow Manager.
 *
 * Barcode Workflow Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * Barcode Workflow Manager is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with Barcode Workflow Manager.  If not, see
 * <http://www.gnu.org/licenses/>.
 */

jQuery(function() {
    $('#marker_sequences').DataTable({
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#marker_sequences').data('source'),
        "columnDefs": [
            { "orderable": false, "targets": 3 }
        ],
        "order": [ 2, 'desc' ]
    });

    $('#marker_sequence_project_ids').chosen({
        allow_single_deselect: true,
        no_results_text: 'No results matched'
    });

    $('#marker_sequence_isolate_display_name').autocomplete({
        source: $('#marker_sequence_isolate_display_name').data('autocomplete-source'),
        minLength: 3
    });
});