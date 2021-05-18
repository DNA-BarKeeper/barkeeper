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

    $('#marker_sequence_search_taxon').autocomplete({
        source: $('#marker_sequence_search_taxon').data('autocomplete-source'),
        minLength: 2
    });

    $('#marker_sequence_search_verified_by').autocomplete({
        source: $('#marker_sequence_search_verified_by').data('autocomplete-source')
    });
});