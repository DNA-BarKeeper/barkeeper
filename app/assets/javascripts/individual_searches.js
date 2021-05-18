jQuery(function() {
    $('#individual_search_specimen_id').autocomplete({
        source: $('#individual_search_specimen_id').data('autocomplete-source'),
        minLength: 2
    });

    $('#individual_search_herbarium').autocomplete({
        source: $('#individual_search_herbarium').data('autocomplete-source')
    });

    $('#individual_search_taxon').autocomplete({
        source: $('#individual_search_taxon').data('autocomplete-source'),
        minLength: 2
    });
});