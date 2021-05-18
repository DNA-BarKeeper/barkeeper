jQuery(function() {
    $('#marker_sequence_project_ids').chosen({
        allow_single_deselect: true,
        no_results_text: 'No results matched'
    });

    $('#marker_sequence_isolate_display_name').autocomplete({
        source: $('#marker_sequence_isolate_display_name').data('autocomplete-source'),
        minLength: 3
    });
});