jQuery ->
  $('#herbaria').DataTable( {
    bProcessing: true
    bServerSide: true
    sAjaxSource: $('#herbaria').data('source')
    "columnDefs": [
      { "orderable": false, "targets": 3 }
    ]
    "order": [1, 'asc']
  } );