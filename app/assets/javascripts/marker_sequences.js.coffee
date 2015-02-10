# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
  $('#marker_sequences').DataTable( {
    sPaginationType: "full_numbers"
    bProcessing: true
    bServerSide: true
    sAjaxSource: $('#marker_sequences').data('source')
    "order": [ 2, 'desc' ]
    "columnDefs": [
      { "orderable": false, "targets": 1}
      { "orderable": false, "targets": 3 }

    ]
  } );
  $('#marker_sequence_isolate_lab_nr').autocomplete source: $('#marker_sequence_isolate_lab_nr').data('autocomplete-source')