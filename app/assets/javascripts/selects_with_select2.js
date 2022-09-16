/*
 * BarKeeper - A versatile web framework to assemble, analyze and manage DNA
 * barcoding data and metadata.
 * Copyright (C) 2022 Kai Müller <kaimueller@uni-muenster.de>, Sarah Wiechers
 * <sarah.wiechers@uni-muenster.de>
 *
 * This file is part of BarKeeper.
 *
 * BarKeeper is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * BarKeeper is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with BarKeeper.  If not, see <http://www.gnu.org/licenses/>.
 */

jQuery(function() {
    // CLUSTERS
    $('#cluster_isolate_id').select2((select2AutocompleteOptions("/isolates/filter", "an isolate")));

    // CONTIGS
    $('#contig_isolate_id').select2((select2AutocompleteOptions("/isolates/filter", "an isolate")));
    $('#contig_marker_id').select2((select2AutocompleteOptions("/markers/filter", "a marker")));
    $('#contig_marker_sequence_id').select2((select2AutocompleteOptions("/marker_sequences/filter", "a marker sequence")));
    $('#contig_verified_by').select2(select2SingleSelectOptions('a user'));
    $('#contig_project_ids').select2(select2MultiselectOptions);

    // CONTIG SEARCHES
    $('#contig_search_name').select2((select2AutocompleteOptions("/contigs/filter?name_only=1", "a contig")));
    $('#contig_search_marker').select2(select2SingleSelectOptions('a marker'));
    $('#contig_search_specimen').select2((select2AutocompleteOptions("/individuals/filter?name_only=1", "a specimen")));
    $('#contig_search_taxon').select2((select2AutocompleteOptions("/taxa/filter?name_only=1", "a taxon")));
    $('#contig_search_verified_by').select2(select2SingleSelectOptions('a user'));

    // FREEZERS
    $('#freezer_lab_id').select2(select2SingleSelectOptions('a lab'));
    $('#freezer_project_ids').select2(select2MultiselectOptions);

    // HOMES
    $('#home_main_logo_id').select2(select2SingleSelectOptions('a logo'));

    // INDIVIDUALS
    $('#individual_taxon_id').select2((select2AutocompleteOptions("/taxa/filter", "a taxon")));
    $('#individual_collection_id').select2(select2SingleSelectOptions('a collection'));
    $('#individual_tissue_id').select2(select2SingleSelectOptions('a tissue type'));
    $('#individual_project_ids').select2(select2MultiselectOptions);

    // INDIVIDUAL SEARCHES
    $('#individual_search_specimen_id').select2((select2AutocompleteOptions("/individuals/filter?name_only=1", "a specimen")));
    $('#individual_search_collection').select2(select2SingleSelectOptions('a collection'));
    $('#individual_search_taxon').select2((select2AutocompleteOptions("/taxa/filter?name_only=1", "a taxon")));

    // ISOLATES
    $('#isolate_project_ids').select2(select2MultiselectOptions);
    $('#isolate_individual_id').select2((select2AutocompleteOptions("/individuals/filter", "a specimen")));
    $('#isolate_tissue_id').select2(select2SingleSelectOptions('a tissue type'));
    $('#isolate_plant_plate_id').select2(select2SingleSelectOptions('a plate'));
    $('#isolate_user_id').select2(select2SingleSelectOptions('a user'));

    // LAB RACKS
    $('#lab_rack_shelf_id').select2(select2SingleSelectOptions('a shelf'));
    $('#lab_rack_project_ids').select2(select2MultiselectOptions);

    // LABS
    $('#lab_project_ids').select2(select2MultiselectOptions);

    // MARKERS
    $('#marker_project_ids').select2(select2MultiselectOptions);
    $('#marker_expected_reads').select2(select2SingleSelectOptions('a number'));

    // MARKER SEQUENCES
    $('#marker_sequence_isolate_id').select2((select2AutocompleteOptions("/isolates/filter", "an isolate")));
    $('#marker_sequence_marker_id').select2(select2SingleSelectOptions('a marker'));
    $('#marker_sequence_project_ids').select2(select2MultiselectOptions);

    // MARKER SEQUENCE SEARCHES
    $('#marker_sequence_search_name').select2((select2AutocompleteOptions("/marker_sequences/filter?name_only=1", "a marker sequence name")));
    $('#marker_sequence_search_marker').select2(select2SingleSelectOptions('a marker'));
    $('#marker_sequence_search_specimen').select2((select2AutocompleteOptions("/individuals/filter?name_only=1", "a specimen")));
    $('#marker_sequence_search_taxon').select2((select2AutocompleteOptions("/taxa/filter?name_only=1", "a taxon")));
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
    $( '#add_project_associated_project').select2(select2SingleSelectOptions('a project'));
    $('#query_associated_taxon').select2((select2AutocompleteOptions("/taxa/filter", "a taxon")));

    // SHELVES
    $('#shelf_freezer_id').select2(select2SingleSelectOptions('a freezer'));
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
    $("#user_default_project_id").select2(select2SingleSelectOptions('a project'));
    $("#user_lab_id").select2(select2SingleSelectOptions('a lab'));
    $("#user_responsibility").select2(select2SingleSelectOptions('a responsibility'));
    $("#user_role").select2(select2SingleSelectOptions('a role'));
    $("#user_project_ids").select2(select2MultiselectOptions);
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
