jQuery(function() {
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

    $('#ngs_run_taxon_name').autocomplete({
        source: $('#ngs_run_taxon_name').data('autocomplete-source')
    });
});