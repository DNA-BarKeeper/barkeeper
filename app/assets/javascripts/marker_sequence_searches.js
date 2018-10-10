jQuery(function() {
    $('#marker_sequence_searches').dataTable({
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#marker_sequence_searches').data('source'),
        "columnDefs": [{
            "orderable": false,
            "targets": 2
        }],
        "order": [ 1, 'desc' ]
    });

    $('#marker_sequence_search_results').dataTable({
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#marker_sequence_search_results').data('source'),
        "columnDefs": [{
            "orderable": false,
            "targets": 3
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