jQuery ->
  $('#isolates').DataTable( {
    bProcessing: true
    bServerSide: true
    sAjaxSource: $('#isolates').data('source')
    "columnDefs": [
      { "orderable": false, "targets": 5 }
    ]
    "order": [ 4, 'desc' ]
  });

  $('#isolates_no_specimen').DataTable( {
    bProcessing: true
    bServerSide: true
    sAjaxSource: $('#isolates_no_specimen').data('source')
    "columnDefs": [
      { "orderable": false, "targets": 5 }
    ]
    "order": [ 0, 'asc' ]
  });

  $('#isolates_duplicates').DataTable( {
    bProcessing: true
    bServerSide: true
    sAjaxSource: $('#isolates_duplicates').data('source')
    "columnDefs": [
      { "orderable": false, "targets": 5 }
    ]
    "order": [ 0, 'desc' ]
  });

  $('#isolate_individual_name').autocomplete
    source: $('#isolate_individual_name').data('autocomplete-source')

  # Jump to correct nav tab
  hash = window.location.hash
  $('.nav-tabs a[href="' + hash + '"]').tab('show');