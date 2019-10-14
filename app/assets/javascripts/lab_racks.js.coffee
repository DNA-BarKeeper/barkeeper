jQuery ->
  $('#lab_racks').DataTable( {
    bProcessing: true
    bServerSide: true
    sAjaxSource: $('#lab_racks').data('source')
    "columnDefs": [
      { "orderable": false, "targets": 5 }
    ]
    "order": [ 0, 'desc' ]
  } );

  $('#lab_rack_project_ids').chosen({
    allow_single_deselect: true
    no_results_text: 'No results matched'
  });