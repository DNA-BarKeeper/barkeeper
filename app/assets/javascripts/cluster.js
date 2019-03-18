jQuery(function() {
    $('#clusters').DataTable({
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#clusters').data('source'),
        "columnDefs": [
            { "orderable": false, "targets": 5 }
        ],
        "order": [ 4, 'desc' ]
    });

    $('#cluster_isolate_name').autocomplete({
        source: $('#cluster_isolate_name').data('autocomplete-source')
    });
});