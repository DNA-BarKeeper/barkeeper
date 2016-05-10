jQuery ->
  $('#plant_plates').DataTable( {
    bProcessing: true
    bServerSide: true
    sAjaxSource: $('#plant_plates').data('source')
    "columnDefs": [
      { "orderable": false, "targets": 2 }
    ]
    "order": [ 1, 'desc' ]
  } );