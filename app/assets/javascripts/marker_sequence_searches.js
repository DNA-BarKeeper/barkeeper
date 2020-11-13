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
    $('#marker_sequence_searches').dataTable({
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#marker_sequence_searches').data('source'),
        "columnDefs": [{
            "orderable": false,
            "targets": 3
        }],
        "order": [ 2, 'desc' ]
    });

    $('#marker_sequence_search_results').dataTable({
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#marker_sequence_search_results').data('source'),
        "columnDefs": [{
            "orderable": false,
            "targets": [1, 3]
        }],
        "order": [ 0, 'asc' ]
    });

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

    $('#marker_sequence_search_name').autocomplete({
        source: $('#marker_sequence_search_name').data('autocomplete-source'),
        minLength: 2
    });

    $('#marker_sequence_search_marker').autocomplete({
        source: $('#marker_sequence_search_marker').data('autocomplete-source')
    });

    $('#marker_sequence_search_specimen').autocomplete({
        source: $('#marker_sequence_search_specimen').data('autocomplete-source'),
        minLength: 2
    });

    $('#marker_sequence_search_species').autocomplete({
        source: $('#marker_sequence_search_species').data('autocomplete-source'),
        minLength: 2
    });

    $('#marker_sequence_search_family').autocomplete({
        source: $('#marker_sequence_search_family').data('autocomplete-source')
    });

    $('#marker_sequence_search_order').autocomplete({
        source: $('#marker_sequence_search_order').data('autocomplete-source')
    })

    $('#marker_sequence_search_higher_order_taxon').autocomplete({
        source: $('#marker_sequence_search_higher_order_taxon').data('autocomplete-source')
    });

    $('#marker_sequence_search_verified_by').autocomplete({
        source: $('#marker_sequence_search_verified_by').data('autocomplete-source')
    });
});