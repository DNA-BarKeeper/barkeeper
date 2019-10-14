jQuery ->
  $('#markers').DataTable( {
    "columnDefs": [
      { "orderable": false, "targets": 2 }
    ],
    "order": [ 7, 'desc' ]
  } );

  $('#marker_project_ids').chosen({
    allow_single_deselect: true
    no_results_text: 'No results matched'
  });
