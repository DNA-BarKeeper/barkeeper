jQuery(function() {
    // FREEZERS
    $('#freezer_project_ids').select2({
        theme: "bootstrap",
        width: '190px'
    });

    // ISOLATES
    $('#isolate_project_ids').select2({
        theme: "bootstrap",
        width: '190px'
    });

    $('#isolate_individual_name').autocomplete({
        source: $('#isolate_individual_name').data('autocomplete-source')
    });

    // LAB RACKS
    $('#lab_rack_project_ids').select2({
        theme: "bootstrap",
        width: '190px'
    });

    // MARKERS
    $('#marker_project_ids').select2({
        theme: "bootstrap",
        width: '190px'
    });

    // MICRONIC PLATES
    $('#micronic_plate_project_ids').select2({
        theme: "bootstrap",
        width: '190px'
    });

    // PLANT PLATES
    $('#plant_plate_project_ids').select2({
        theme: "bootstrap",
        width: '190px'
    });

    // PRIMERS
    $('#primer_project_ids').select2({
        theme: "bootstrap",
        width: '190px'
    });

    // CLUSTERS
    $('#cluster_isolate_name').autocomplete({
        source: $('#cluster_isolate_name').data('autocomplete-source')
    });

    // CONTIG SEARCHES
    $('#contig_search_name').autocomplete({
        source: $('#contig_search_name').data('autocomplete-source'),
        minLength: 2
    });

    $('#contig_search_marker').autocomplete({
        source: $('#contig_search_marker').data('autocomplete-source')
    });

    $('#contig_search_specimen').autocomplete({
        source: $('#contig_search_specimen').data('autocomplete-source'),
        minLength: 2
    });

    $('#contig_search_taxon').autocomplete({
        source: $('#contig_search_taxon').data('autocomplete-source')
    });

    $('#contig_search_verified_by').autocomplete({
        source: $('#contig_search_verified_by').data('autocomplete-source')
    });

    // CONTIGS
    $('#contig_isolate_name').autocomplete({
        source: $('#contig_isolate_name').data('autocomplete-source')
    });

    $('#contig_marker_sequence_name').autocomplete({
        source: $('#contig_marker_sequence_name').data('autocomplete-source')
    });

    $('#contig_project_ids').select2({
        theme: "bootstrap",
        width: '190px'
    });

    // INDIVIDUAL SEARCHES
    $('#individual_search_specimen_id').autocomplete({
        source: $('#individual_search_specimen_id').data('autocomplete-source'),
        minLength: 2
    });

    $('#individual_search_herbarium').autocomplete({
        source: $('#individual_search_herbarium').data('autocomplete-source')
    });

    $('#individual_search_taxon').autocomplete({
        source: $('#individual_search_taxon').data('autocomplete-source'),
        minLength: 2
    });

    // INDIVIDUALS
    $('#individual_project_ids').select2({
        theme: "bootstrap",
        width: '190px'
    });

    $('#individual_taxon_name').autocomplete({
        source: $('#individual_taxon_name').data('autocomplete-source')
    });

    $('#individual_collected').datepicker({
        dateFormat: 'yy-mm-dd'
    });

    // ISSUES
    $('#issue_project_ids').select2({
        theme: "bootstrap",
        width: '190px'
    });

    // LABS
    $('#lab_project_ids').select2({
        theme: "bootstrap",
        width: '190px'
    });

    // MARKER SEQUENCE SEARCHES
    $('#marker_sequence_search_name').autocomplete({
        source: $('#marker_sequence_search_name').data('autocomplete-source'),
        minLength: 2
    });

    $('#marker_sequence_search_marker').autocomplete({
        source: $('#marker_sequence_search_marker').data('autocomplete-source')
    });

    $('#marker_sequence_search_specimen').autocomplete({
        source: $('#marker_sequence_search_specimen').data('autocomplete-source'),
        minLength: 2
    });

    $('#marker_sequence_search_taxon').autocomplete({
        source: $('#marker_sequence_search_taxon').data('autocomplete-source'),
        minLength: 2
    });

    $('#marker_sequence_search_verified_by').autocomplete({
        source: $('#marker_sequence_search_verified_by').data('autocomplete-source')
    });

    // MARKER SEQUENCES
    $('#marker_sequence_project_ids').select2({
        theme: "bootstrap",
        width: '190px'
    });

    $('#marker_sequence_isolate_display_name').autocomplete({
        source: $('#marker_sequence_isolate_display_name').data('autocomplete-source'),
        minLength: 3
    });

    // NGS RUNS
    $('#ngs_run_taxon_name').autocomplete({
        source: $('#ngs_run_taxon_name').data('autocomplete-source')
    });

    // PRIMER READS
    $('#primer_read_project_ids').select2({
        theme: "bootstrap",
        width: '190px'
    });

    $('#primer_read_contig_name').autocomplete( {
        source: $('#primer_read_contig_name').data('autocomplete-source')
    });

    // PROJECTS
    $('#associated_taxon').autocomplete({
        source: $('#associated_taxon').data('autocomplete-source')
    });

    // SHELVES
    $('#shelf_project_ids').select2({
        theme: "bootstrap",
        width: '190px'
    });

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

    $('#taxon_search').autocomplete({
        source: $('#taxon_search').data('autocomplete-source')});

    // DEPRECATED
    $('#family_project_ids').select2({
        theme: "bootstrap",
        width: '190px'
    });

    $('#order_project_ids').select2({
        theme: "bootstrap",
        width: '190px'
    });

    $('#species_project_ids').select2({
        theme: "bootstrap",
        width: '190px'
    });

    $('#higher_order_taxon_marker_ids').select2({
        theme: "bootstrap",
        width: '190px'
    });

    $('#higher_order_taxon_project_ids').select2({
        theme: "bootstrap",
        width: '190px'
    });
});
