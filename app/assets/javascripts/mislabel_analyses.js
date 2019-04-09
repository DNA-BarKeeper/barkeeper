jQuery(function() {
    $('#mislabel_analyses').dataTable({
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#mislabel_analyses').data('source'),
        "columnDefs": [{
            "orderable": false,
            "targets": [1, 4]
        }],
        "order": [3, 'desc']
    });

    $('#mislabel_analysis_results').dataTable({
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#mislabel_analysis_results').data('source'),
        "columnDefs": [{
            "orderable": false,
            "targets": 6
        }],
        "order": [0, 'asc']
    });
});