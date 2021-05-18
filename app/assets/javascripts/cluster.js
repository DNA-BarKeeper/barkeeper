jQuery(function() {
    $('#cluster_isolate_name').autocomplete({
        source: $('#cluster_isolate_name').data('autocomplete-source')
    });
});