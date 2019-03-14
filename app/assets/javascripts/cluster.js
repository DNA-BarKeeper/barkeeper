jQuery(function() {
    $('#clusters').DataTable({
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#clusters').data('source'),
        "columnDefs": [
            { "orderable": false, "targets": 4 }
        ],
        "order": [ 3, 'desc' ]
    });
});