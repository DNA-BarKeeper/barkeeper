jQuery ->
  $('#orders').DataTable( {
    "columnDefs": [
      { "orderable": false, "targets": 2 }
    ]
  } );