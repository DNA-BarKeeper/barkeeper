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