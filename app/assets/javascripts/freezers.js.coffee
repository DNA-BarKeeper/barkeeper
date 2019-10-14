jQuery ->
  $('#freezers').DataTable( {
    bProcessing: true
    bServerSide: true
    sAjaxSource: $('#freezers').data('source')
    "columnDefs": [
      { "orderable": false, "targets": 3 }
    ]
    "order": [ 2, 'desc' ]
  } );

  $('#freezer_project_ids').chosen({
    allow_single_deselect: true
    no_results_text: 'No results matched'
  });