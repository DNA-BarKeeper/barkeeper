jQuery ->
  $('#micronic_plates').DataTable( {
    bProcessing: true
    bServerSide: true
    sAjaxSource: $('#micronic_plates').data('source')
    "columnDefs": [
      { "orderable": false, "targets": 6 }
    ]
    "order": [ 5, 'desc' ]
  } );

  $('#micronic_plate_project_ids').chosen({
    allow_single_deselect: true
    no_results_text: 'No results matched'
  });