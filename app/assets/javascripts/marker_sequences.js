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


    $('#marker_sequence_isolate_display_name').autocomplete({
        source: $('#marker_sequence_isolate_display_name').data('autocomplete-source')
    });
});