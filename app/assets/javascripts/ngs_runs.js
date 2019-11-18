jQuery(function() {
    $('#ngs_runs').dataTable({
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#ngs_runs').data('source'),
        "columnDefs": [{
            "targets": 2,
            "orderable": false
        }],
        "order": [1, 'desc']
    });

    $('#ngs_run_results').dataTable({
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#ngs_run_results').data('source'),
        "paging": false,
        "scrollX": true,
        "sScrollY": document.body.clientHeight * 80 / 100,
        "columnDefs": [{
            "targets": 3,
            "orderable": false
        }],
        "order": [0, 'desc']
    });

    // Make file input multiple if package map was selected/uploaded
    var set_tag_map = $('#ngs_run_set_tag_map');
    var tag_primer_map = $("#ngs_run_tag_primer_map");

    if(set_tag_map.val() || $('#ngs_run_delete_set_tag_map').length) { // Package Map is selected or was uploaded before
        tag_primer_map.attr('multiple','multiple')
    }
    else {
        tag_primer_map.removeAttr('multiple')
    }

    set_tag_map.change(function() {
        if($(this).val()) {
            tag_primer_map.attr('multiple','multiple')
        }
        else {
            tag_primer_map.removeAttr('multiple');
            tag_primer_map.val("");
        }
    });
});