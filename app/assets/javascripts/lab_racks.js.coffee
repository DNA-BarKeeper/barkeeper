jQuery ->
  $('#lab_racks').DataTable( {
    bProcessing: true
    bServerSide: true
    sAjaxSource: $('#lab_racks').data('source')
    "columnDefs": [
      { "orderable": false, "targets": 2 }
      { "orderable": false, "targets": 3 }
      { "orderable": false, "targets": 5 }
    ]
    "order": [ 0, 'desc' ]
  } );