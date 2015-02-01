
jQuery ->
  $('#families').DataTable( {
    "columnDefs": [
      { "orderable": false, "targets": 2 }
    ]
  } );