jQuery(function() {
    $('#higher_order_taxa').DataTable({
        "columnDefs": [
            {"orderable": false, "targets": 3}
        ],
        "order": [ 2, 'asc' ]
    });
    //$('select#higher_order_taxon_marker_ids').select2({
    //    width: '100%'
    //});
});