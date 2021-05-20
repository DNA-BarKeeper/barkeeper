jQuery(function() {
    // CLUSTERS
    $('#cluster_isolate_id').select2((select2AutocompleteOptions("/isolates/filter", "an isolate")));

    // CONTIGS
    $('#contig_isolate_id').select2((select2AutocompleteOptions("/isolates/filter", "an isolate")));
    $('#contig_marker_id').select2((select2AutocompleteOptions("/markers/filter", "a marker")));
    $('#contig_marker_sequence_id').select2((select2AutocompleteOptions("/marker_sequences/filter", "a marker sequence")));
    $('#contig_project_ids').select2(select2MultiselectOptions);

    // CONTIG SEARCHES
    $('#contig_search_name').select2((select2AutocompleteOptions("/contigs/filter", "a contig")));
    $('#contig_search_marker').select2(select2SingleSelectOptions('a marker'));
    $('#contig_search_specimen').select2((select2AutocompleteOptions("/individuals/filter", "a specimen")));
    $('#contig_search_taxon').select2((select2AutocompleteOptions("/taxa/filter", "a taxon")));
    $('#contig_search_verified_by').select2(select2SingleSelectOptions('a user'));

    // FREEZERS
    $('#freezer_lab_id').select2(select2SingleSelectOptions('a lab'));
    $('#freezer_project_ids').select2(select2MultiselectOptions);

    // INDIVIDUALS
    $('#individual_taxon_id').select2((select2AutocompleteOptions("/taxa/filter", "a taxon")));
    $('#individual_herbarium_id').select2(select2SingleSelectOptions('an herbarium'));
    $('#individual_tissue_id').select2(select2SingleSelectOptions('a tissue type'));
    $('#individual_project_ids').select2(select2MultiselectOptions);

    // INDIVIDUAL SEARCHES
    $('#individual_search_specimen_id').select2((select2AutocompleteOptions("/individuals/filter", "a specimen")));
    $('#individual_search_herbarium_id').select2(select2SingleSelectOptions('an herbarium'));
    $('#individual_search_taxon').select2((select2AutocompleteOptions("/taxa/filter", "a taxon")));

    // ISOLATES
    $('#isolate_project_ids').select2(select2MultiselectOptions);
    $('#isolate_individual_id').select2((select2AutocompleteOptions("/individuals/filter", "a specimen")));
    $('#isolate_tissue_id').select2(select2SingleSelectOptions('a tissue type'));
    $('#isolate_plant_plate_id').select2(select2SingleSelectOptions('a plate'));
    $('#isolate_user_id').select2(select2SingleSelectOptions('a user'));

    // ISSUES
    $('#issue_project_ids').select2(select2MultiselectOptions);

    // LAB RACKS
    $('#lab_rack_shelf_id').select2(select2SingleSelectOptions('a shelf'));
    $('#lab_rack_project_ids').select2(select2MultiselectOptions);

    // LABS
    $('#lab_project_ids').select2(select2MultiselectOptions);

    // MARKERS
    $('#marker_project_ids').select2(select2MultiselectOptions);

    // MARKER SEQUENCES
    $('#marker_sequence_isolate_id').select2((select2AutocompleteOptions("/isolates/filter", "an isolate")));
    $('#marker_sequence_marker_id').select2(select2SingleSelectOptions('a marker'));
    $('#marker_sequence_project_ids').select2(select2MultiselectOptions);

    // MARKER SEQUENCE SEARCHES
    $('#marker_sequence_search_name').select2((select2AutocompleteOptions("/marker_sequences/filter", "a marker sequence name")));
    $('#marker_sequence_search_marker').select2(select2SingleSelectOptions('a marker'));
    $('#marker_sequence_search_specimen').select2((select2AutocompleteOptions("/individuals/filter", "a specimen")));
    $('#marker_sequence_search_taxon').select2((select2AutocompleteOptions("/taxa/filter", "a taxon")));
    $('#marker_sequence_search_verified_by').select2(select2SingleSelectOptions('a user'));

    // MICRONIC PLATES
    $('#micronic_plate_lab_rack_id').select2(select2SingleSelectOptions('a rack'));
    $('#micronic_plate_project_ids').select2(select2MultiselectOptions);

    // NGS RUNS
    $('#ngs_run_taxon_id').select2((select2AutocompleteOptions("/taxa/filter", "a taxon")));

    // PLANT PLATES
    $('#plant_plate_project_ids').select2(select2MultiselectOptions);

    // PRIMER READS
    $('#primer_read_contig_id').select2((select2AutocompleteOptions("/contigs/filter", "a contig")));
    $('#primer_read_project_ids').select2(select2MultiselectOptions);

    // PRIMERS
    $('#primer_marker_id').select2(select2SingleSelectOptions('a marker'));
    $('#primer_project_ids').select2(select2MultiselectOptions);

    // PROJECTS
    $('#project_user_ids').select2(select2MultiselectOptions);
    $( '#associated_project_ids').select2(select2MultiselectOptions);
    $('#query_associated_taxon').select2((select2AutocompleteOptions("/taxa/filter", "a taxon")));

    // SHELVES
    $('#shelf_project_ids').select2(select2MultiselectOptions);

    // TAXA
    $( "#taxon_taxonomic_rank" ).select2(select2SingleSelectOptions('a rank'));
    $( "#taxon_parent_id" ).select2(select2AutocompleteOptions("/taxa/filter", "a taxon"));
    $('#taxon_project_ids').select2(select2MultiselectOptions);

    $("#taxonomy_root_select").select2({
        theme: "bootstrap",
        placeholder: 'Select a taxon',
        minimumResultsForSearch: 15,
        allowClear: false,
        width: 'auto'
    });

    $('#taxon_search').select2(select2AutocompleteOptions("/taxa/filter", "a taxon", 'auto'));

    // USERS
    $("#user_lab_id").select2(select2SingleSelectOptions('a lab'));
    $("#user_responsibility_ids").select2(select2MultiselectOptions);
    $("#user_project_ids").select2(select2MultiselectOptions);

    // DEPRECATED
    $('#family_project_ids').select2(select2MultiselectOptions);

    $('#order_project_ids').select2(select2MultiselectOptions);

    $('#species_project_ids').select2(select2MultiselectOptions);

    $('#higher_order_taxon_marker_ids').select2(select2MultiselectOptions);

    $('#higher_order_taxon_project_ids').select2(select2MultiselectOptions);
});

let select2MultiselectOptions = {
    theme: "bootstrap",
    width: '190px'
};

function select2SingleSelectOptions(recordName, width='190px') {
    return {
        theme: "bootstrap",
        placeholder: 'Select ' + recordName,
        minimumResultsForSearch: 15,
        allowClear: true,
        width: width
    }
}

function select2AutocompleteOptions(filter_url, recordName, width='190px') {
    return {
        theme: "bootstrap",
        minimumResultsForSearch: 15,
        placeholder: 'Select ' + recordName,
        allowClear: true,
        minimumInputLength: 2,
        width: width,
        ajax: {
            url: filter_url,
            delay: 400,
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
                        text: item.name
                    });
                });
                return {
                    results: results
                };
            },
        },
    };
}
