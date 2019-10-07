jQuery ->
  $('#plant_plates').DataTable({
    bProcessing: true
    bServerSide: true
    sAjaxSource: $('#plant_plates').data('source')
    "columnDefs": [
      { "orderable": false, "targets": 2 }
    ]
    "order": [ 1, 'desc' ]
  });

  $('#plant_plate_project_ids').chosen({
    allow_single_deselect: true
    no_results_text: 'No results matched'
  });