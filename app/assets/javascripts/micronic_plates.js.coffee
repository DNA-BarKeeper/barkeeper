jQuery ->
  $('#micronic_plates').DataTable( {
    bProcessing: true
    bServerSide: true
    sAjaxSource: $('#micronic_plates').data('source')
    "columnDefs": [
      { "orderable": false, "targets": 6 }
    ]
    "order": [ 5, 'desc' ]
  } );