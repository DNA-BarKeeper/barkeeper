# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
  $('#marker_sequences').DataTable( {
    "order": [ 7, 'desc' ]
    "columnDefs": [
      { "orderable": false, "targets": 8 }
    ]
  } );
  $('#marker_sequence_isolate_lab_nr').autocomplete source: $('#marker_sequence_isolate_lab_nr').data('autocomplete-source')