jQuery ->
  $('#isolates').DataTable( {
    bProcessing: true
    bServerSide: true
    sAjaxSource: $('#isolates').data('source')
    "columnDefs": [
      { "orderable": false, "targets": 4 }
    ]
    "order": [ 3, 'desc' ]
  });

  $('#isolates_no_specimen').DataTable( {
    bProcessing: true
    bServerSide: true
    sAjaxSource: $('#isolates_no_specimen').data('source')
    "columnDefs": [
      { "orderable": false, "targets": 4 }
    ]
    "order": [ 3, 'desc' ]
  });

  $('#isolates_duplicates').DataTable( {
    bProcessing: true
    bServerSide: true
    sAjaxSource: $('#isolates_duplicates').data('source')
    "columnDefs": [
      { "orderable": false, "targets": 4 }
    ]
    "order": [ 3, 'desc' ]
  });

  $('#isolate_individual_name').autocomplete
    source: $('#isolate_individual_name').data('autocomplete-source')