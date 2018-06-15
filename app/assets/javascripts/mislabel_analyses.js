jQuery(function() {
    $('#mislabel_analyses').dataTable({
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#mislabel_analyses').data('source'),
        "columnDefs": [{
            "orderable": false,
            "targets": 2
        }],
        "order": [1, 'desc']
    });
});