jQuery ->
  $('#families').DataTable( {
    "columnDefs": [
      { "orderable": false, "targets": 1 }
      { "orderable": false, "targets": 2 }
    ]
  } );