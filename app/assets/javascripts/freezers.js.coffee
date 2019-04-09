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