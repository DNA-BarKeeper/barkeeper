jQuery(function() {
    $('#marker_sequences').DataTable({
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#marker_sequences').data('source'),
        "columnDefs": [
            { "orderable": false, "targets": 3 }
        ],
        "order": [ 2, 'desc' ]
    });


    $('#marker_sequence_isolate_lab_isolation_nr').autocomplete({
        source: $('#marker_sequence_isolate_lab_isolation_nr').data('autocomplete-source')
    });
});