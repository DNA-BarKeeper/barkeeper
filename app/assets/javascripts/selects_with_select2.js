jQuery(function() {
    // TAXA
    $( "#taxon_taxonomic_rank" ).select2({
        theme: "bootstrap",
        minimumResultsForSearch: 15,
        placeholder: 'Select a rank',
        allowClear: true,
        width: '190px'
    });

    $( "#taxon_parent_id" ).select2({
        theme: "bootstrap",
        minimumResultsForSearch: 15,
        placeholder: 'Select a taxon',
        allowClear: true,
        minimumInputLength: 3,
        width: '190px',
        ajax: {
            url: "/taxa/filter",
            data: function (params) {
                return {
                    term: params.term
                };
            },
            processResults: function (data) {
                var results = [];
                $.each(data, function(index, item){
                    results.push({
                        id: item.id,
                        text: item.scientific_name
                    });
                });
                return {
                    results: results
                };
            },
        },
    });

    $('#taxon_project_ids').select2({
        theme: "bootstrap",
        width: '190px'
    });

    $("#taxonomy_root_select").select2({
        theme: "bootstrap",
        minimumResultsForSearch: 15,
        placeholder: 'Select a taxon',
        width: 'auto'
    });
});
