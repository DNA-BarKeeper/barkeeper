jQuery(function() {
    $('#higher_order_taxa').DataTable({
        "columnDefs": [
            {"orderable": false, "targets": 3}
        ],
        "order": [ 2, 'asc' ]
    });

    $('#higher_order_taxon_marker_ids').chosen({
        allow_single_deselect: true,
        no_results_text: 'No results matched',
        width: '400px'
    });
});