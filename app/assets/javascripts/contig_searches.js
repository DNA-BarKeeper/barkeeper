jQuery(function() {
    //initially hide global spinner
    var $global_spinner=$(".sk-circle").hide();
    var $buttons = $('#buttons').hide();

    $(document)
        .ajaxStart(function () {
            $global_spinner.show();
        })
        .ajaxStop(function () {
            $global_spinner.hide();
            $buttons.show();
        });

    $('#contig_search').DataTable({
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#contig_search').data('source'),
        "columnDefs": [
            { "orderable": false, "targets": 1 },
            { "orderable": false, "targets": 2 },
            { "orderable": false, "targets": 5 }
        ],
        "order": [ 0, 'asc' ]
    });
});
