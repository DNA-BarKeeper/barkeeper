jQuery ->
  $('#orders').DataTable( {
    "columnDefs": [
      { "orderable": false, "targets": 2 }
    ]
  } );

  $('#order_project_ids').chosen({
    allow_single_deselect: true
    no_results_text: 'No results matched'
  });