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

    $('#fastq_upload').fileupload(
        {
            dataType: "script",
            add: function(e, data) {
                data.context = $(tmpl("template-upload", data.files[0]));
                $('#fastq_upload').append(data.context);
                return data.submit();
            },
            progress: function(e, data) {
                var progress;
                if (data.context) {
                    progress = parseInt(data.loaded / data.total * 100, 10);
                    return data.context.find('.progress-bar').css('width', progress + '%');
                }
            }
        }
    );

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