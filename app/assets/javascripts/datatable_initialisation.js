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
    // FREEZERS
    $('#freezers').DataTable( {
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#freezers').data('source'),
        "columnDefs": [
            { "orderable": false, "targets": 3 }
        ],
        "order": [ 2, 'desc' ]
    } );

    //COLLECTIONS
    $('#collections').DataTable( {
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#collections').data('source'),
        "columnDefs": [
            { "orderable": false, "targets": 3 }
        ],
        "order": [1, 'asc']
    } );

    // ISOLATES
    $('#isolates').DataTable( {
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#isolates').data('source'),
        "columnDefs": [
            { "orderable": false, "targets": 5 }
        ],
        "order": [ 4, 'desc' ]
    } );

    $('#isolates_no_specimen').DataTable( {
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#isolates_no_specimen').data('source'),
        "columnDefs": [
            { "orderable": false, "targets": 5 }
        ],
        "order": [ 0, 'asc' ]
    } );

    $('#isolates_duplicates').DataTable( {
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#isolates_duplicates').data('source'),
        "columnDefs": [
            { "orderable": false, "targets": 5 }
        ],
        "order": [ 0, 'desc' ]
    } );

    // LAB RACKS
    $('#lab_racks').DataTable( {
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#lab_racks').data('source'),
        "columnDefs": [
            { "orderable": false, "targets": 5 }
        ],
        "order": [ 0, 'desc' ]
    } );

    // MICRONIC PLATES
    $('#micronic_plates').DataTable( {
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#micronic_plates').data('source'),
        "columnDefs": [
            { "orderable": false, "targets": 6 }
        ],
        "order": [ 5, 'desc' ]
    } );

    // PLANT PLATES
    $('#plant_plates').DataTable( {
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#plant_plates').data('source'),
        "columnDefs": [
            { "orderable": false, "targets": 2 }
        ],
        "order": [ 1, 'desc' ]
    } );

    // PRIMERS
    $('#primers').DataTable( {
        "order": [ 4, 'desc' ],
        "columnDefs": [
            { "orderable": false, "targets": 5 }
        ]
    } );

    // USERS
    $('#users').DataTable( {
        "columnDefs": [
            { "orderable": false, "targets": 3 },
            { "orderable": false, "targets": 7 }
        ]
    } );

    // CLUSTERS
    $('#clusters').DataTable( {
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#clusters').data('source'),
        "columnDefs": [
            { "orderable": false, "targets": 5 }
        ],
        "order": [ 4, 'desc' ]
    } );

    // CONTIG SEARCHES
    $('#contig_searches').dataTable( {
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#contig_searches').data('source'),
        "columnDefs": [{
            "targets": 3,
            "orderable": false
        }],
        "order": [ 2, 'desc' ]
    } );

    $('#contig_search_results').dataTable( {
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#contig_search_results').data('source'),
        "columnDefs": [{
            "targets": [1, 2, 5],
            "orderable": false
        }],
        "order": [ 0, 'asc' ]
    } );

    // CONTIGS
    $('#contigs').DataTable( {
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#contigs').data('source'),
        "columnDefs": [
            { "orderable": false, "targets": 5 }
        ],
        "order": [ 4, 'desc' ]
    } );

    $('#contigs-duplicates').DataTable( {
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#contigs-duplicates').data('source'),
        "columnDefs": [
            { "orderable": false, "targets": 5 }
        ],
        "order": [ 0, 'asc' ]
    } );

    // INDIVIDUAL SEARCHES
    $('#individual_searches').dataTable( {
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#individual_searches').data('source'),
        "columnDefs": [{
            "orderable": false,
            "targets": 3
        }],
        "order": [ 2, 'desc' ]
    } );

    $('#individual_search_results').dataTable( {
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#individual_search_results').data('source'),
        "columnDefs": [{
            "orderable": false,
            "targets": [1, 6]
        }],
        "order": [ 0, 'asc' ]
    } );

    // INDIVIDUALS
    $('#individuals').DataTable( {
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#individuals').data('source'),
        "columnDefs": [
            { "orderable": false, "targets": 6 }
        ],
        "order": [5, 'desc']
    } );

    // ISSUES
    $('#issues').dataTable( {
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#issues').data('source'),
        "columnDefs": [
            { "orderable": false, "targets": 1 },
            { "orderable": false, "targets": 2 }
        ],
        "order": [ 3, 'desc' ]
    } );

    // MARKERS SEQUENCE SEARCHES
    $('#marker_sequence_searches').dataTable( {
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#marker_sequence_searches').data('source'),
        "columnDefs": [{
            "orderable": false,
            "targets": 3
        }],
        "order": [ 2, 'desc' ]
    } );

    $('#marker_sequence_search_results').dataTable( {
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#marker_sequence_search_results').data('source'),
        "columnDefs": [{
            "orderable": false,
            "targets": [1, 3]
        }],
        "order": [ 0, 'asc' ]
    } );

    // MARKER SEQUENCES
    $('#marker_sequences').DataTable( {
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#marker_sequences').data('source'),
        "columnDefs": [
            { "orderable": false, "targets": 3 }
        ],
        "order": [ 2, 'desc' ]
    } );

    // MISLABEL ANALYSES
    $('#mislabel_analyses').dataTable( {
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#mislabel_analyses').data('source'),
        "columnDefs": [{
            "orderable": false,
            "targets": [1, 4]
        }],
        "order": [3, 'desc']
    } );

    $('#mislabel_analysis_results').dataTable( {
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#mislabel_analysis_results').data('source'),
        "columnDefs": [{
            "orderable": false,
            "targets": 6
        }],
        "order": [0, 'asc']
    } );

    // NGS RUNS
    $('#ngs_runs').dataTable( {
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#ngs_runs').data('source'),
        "columnDefs": [{
            "targets": 2,
            "orderable": false
        }],
        "order": [1, 'desc']
    } );

    $('#ngs_run_results').dataTable( {
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#ngs_run_results').data('source'),
        "sScrollY": document.body.clientHeight * 70 / 100,
        "scrollX": true,
        scroller: {
            loadingIndicator: true,
            displayBuffer: 2
        },
        deferRender:    true,
        "columnDefs": [{
            "targets": 3,
            "orderable": false
        }],
        "order": [0, 'desc']
    } );

    // PRIMER READS
    $('#primer_reads').DataTable( {
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#primer_reads').data('source'),
        "columnDefs": [
            { "orderable": false, "targets": 4 }
        ],
        "order": [ 3, 'desc' ]
    } );

    $('#primer_reads-duplicates').DataTable( {
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#primer_reads-duplicates').data('source'),
        "columnDefs": [
            { "orderable": false, "targets": 4 }
        ],
        "order": [ 0, 'asc' ]
    } );

    $('#reads_without_contigs').DataTable( {
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#reads_without_contigs').data('source'),
        "columnDefs": [
            { "orderable": false, "targets": 4 }
        ],
        "order": [ 3, 'desc' ]
    } );

    // TAXA
    $('#associated_individuals').DataTable( {
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#associated_individuals').data('source'),
        "columnDefs": [
            { "orderable": false, "targets": 6 }
        ],
        "order": [5, 'desc']
    } );

    $('#direct_children').DataTable( {
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#direct_children').data('source'),
        "columnDefs": [
            { "orderable": false, "targets": 5 }
        ],
        "order": [ 0, 'asc' ]
    } );

    $('#orphans').DataTable( {
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#orphans').data('source'),
        "columnDefs": [
            { "orderable": false, "targets": 5 }
        ],
        "order": [ 0, 'asc' ]
    } );
} );
