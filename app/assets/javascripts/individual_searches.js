jQuery(function() {
    $('#individual_searches').dataTable({
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#individual_searches').data('source'),
        "columnDefs": [{
            "orderable": false,
            "targets": 3
        }],
        "order": [ 2, 'desc' ]
    });

    $('#individual_search_results').dataTable({
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#individual_search_results').data('source'),
        "columnDefs": [{
            "orderable": false,
            "targets": [1, 6]
        }],
        "order": [ 0, 'asc' ]
    });

    $('#individual_search_specimen_id').autocomplete({
        source: $('#individual_search_specimen_id').data('autocomplete-source'),
        minLength: 2
    });

    $('#individual_search_species').autocomplete({
        source: $('#individual_search_species').data('autocomplete-source'),
        minLength: 2
    });

    $('#individual_search_family').autocomplete({
        source: $('#individual_search_family').data('autocomplete-source')
    });

    $('#individual_search_order').autocomplete({
        source: $('#individual_search_order').data('autocomplete-source')
    });
});