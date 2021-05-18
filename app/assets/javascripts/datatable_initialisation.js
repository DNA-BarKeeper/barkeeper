jQuery(function() {
    // TAXA
    $('#associated_individuals').DataTable({
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#associated_individuals').data('source'),
        "columnDefs": [
            { "orderable": false, "targets": 6 }
        ],
        "order": [5, 'desc']
    });

    $('#direct_children').DataTable({
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#direct_children').data('source'),
        "columnDefs": [
            { "orderable": false, "targets": 5 }
        ],
        "order": [ 0, 'asc' ]
    });

    $('#orphans').DataTable({
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#orphans').data('source'),
        "columnDefs": [
            { "orderable": false, "targets": 5 }
        ],
        "order": [ 0, 'asc' ]
    });
});
