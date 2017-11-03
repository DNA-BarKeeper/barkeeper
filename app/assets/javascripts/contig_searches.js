jQuery(function() {
    $('#contig_search').dataTable({
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

    $('#contig_search_min_age').datepicker({
        dateFormat: 'yy-mm-dd'
    });

    $('#contig_search_max_age').datepicker({
        dateFormat: 'yy-mm-dd'
    });

    $('#contig_search_min_update').datepicker({
        dateFormat: 'yy-mm-dd'
    });

    $('#contig_search_max_update').datepicker({
        dateFormat: 'yy-mm-dd'
    });

    $('#contig_search_name').select2({
        theme: "bootstrap",
        placeholder: "Select a contig name",
        allowClear: true,
        dropdownAutoWidth : true,
        width: '172px',
        minimumInputLength: 1
    });

    $('#contig_search_marker_id').select2({
        theme: "bootstrap",
        placeholder: "Select a marker",
        allowClear: true,
        dropdownAutoWidth : true,
        width: '172px'
    });

    $('#contig_search_specimen').select2({
        theme: "bootstrap",
        placeholder: "Select a specimen",
        allowClear: true,
        dropdownAutoWidth : true,
        width: '172px',
        minimumInputLength: 1
    });

    $('#contig_search_species').select2({
        theme: "bootstrap",
        placeholder: "Select a species",
        allowClear: true,
        dropdownAutoWidth : true,
        width: '172px'
    });

    $('#contig_search_family').select2({
        theme: "bootstrap",
        placeholder: "Select a family",
        allowClear: true,
        dropdownAutoWidth : true,
        width: '172px'
    });

    $('#contig_search_order_id').select2({
        theme: "bootstrap",
        placeholder: "Select an order",
        allowClear: true,
        dropdownAutoWidth : true,
        width: '172px'
    });
});
