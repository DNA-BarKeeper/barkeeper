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
    $('#contig_searches').dataTable({
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#contig_searches').data('source'),
        "columnDefs": [{
            "targets": 3,
            "orderable": false
        }],
        "order": [ 2, 'desc' ]
    });

    $('#contig_search_results').dataTable({
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#contig_search_results').data('source'),
        "columnDefs": [{
            "targets": [1, 2, 5],
            "orderable": false
        }],
        "order": [ 0, 'asc' ]
    });

    $('#contig_search_min_age').datepicker({
        dateFormat: 'yy-mm-dd'
    });

    $('#contig_search_max_age').datepicker({
        dateFormat: 'yy-mm-dd'
    });

    $('#contig_search_min_update').datepicker({
        dateFormat: 'yy-mm-dd'
    });

    $('#contig_search_max_update').datepicker({
        dateFormat: 'yy-mm-dd'
    });

    $('#contig_search_name').autocomplete({
        source: $('#contig_search_name').data('autocomplete-source'),
        minLength: 2
    });

    $('#contig_search_marker').autocomplete({
        source: $('#contig_search_marker').data('autocomplete-source')
    });

    $('#contig_search_specimen').autocomplete({
        source: $('#contig_search_specimen').data('autocomplete-source'),
        minLength: 2
    });

    $('#contig_search_species').autocomplete({
        source: $('#contig_search_species').data('autocomplete-source'),
        minLength: 2
    });

    $('#contig_search_family').autocomplete({
        source: $('#contig_search_family').data('autocomplete-source')
    });

    $('#contig_search_order').autocomplete({
        source: $('#contig_search_order').data('autocomplete-source')
    });

    $('#contig_search_verified_by').autocomplete({
        source: $('#contig_search_verified_by').data('autocomplete-source')
    });
});
