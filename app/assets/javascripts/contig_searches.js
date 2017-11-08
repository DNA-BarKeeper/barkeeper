jQuery(function() {
    $('#contig_searches').dataTable({
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#contig_searches').data('source'),
        "order": [ 0, 'asc' ]
    });

    $('#contig_search_results').dataTable({
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#contig_search_results').data('source'),
        "columnDefs": [
            { "orderable": false, "targets": 1 },
            { "orderable": false, "targets": 2 },
            { "orderable": false, "targets": 5 }
        ],
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
});
