jQuery(function() {
    $('#issues').dataTable(
        {
            bProcessing: true,
            bServerSide: true,
            sAjaxSource: $('#issues').data('source'),
            "columnDefs": [
                { "orderable": false, "targets": 1 },
                { "orderable": false, "targets": 2 }
            ],
            "order": [ 3, 'desc' ]
        }
    );
});

