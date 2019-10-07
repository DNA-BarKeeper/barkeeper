jQuery(function() {
    $('#higher_order_taxon_marker_ids').chosen({
        allow_single_deselect: true,
        no_results_text: 'No results matched'
    });

    $('#higher_order_taxon_project_ids').chosen({
        allow_single_deselect: true,
        no_results_text: 'No results matched'
    });

    return $('#higher_order_taxon_parent_id').autocomplete({
        source: $('#higher_order_taxon_parent_id').data('autocomplete-source')
    });
});