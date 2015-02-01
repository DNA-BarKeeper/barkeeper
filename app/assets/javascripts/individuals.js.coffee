# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/


jQuery ->
  $('#individuals').DataTable( {
    "order": [ 20, 'desc' ]
    "columnDefs": [
      { "orderable": false, "targets": 21 }
    ]
  } );
  $('#individual_specimen_id').autocomplete source: $('#individual_specimen_id').data('autocomplete-source')