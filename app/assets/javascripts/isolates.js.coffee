# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
  $('#isolates').DataTable( {
    "order": [ 8, 'desc' ]
    "columnDefs": [
      { "orderable": false, "targets": 9 }
    ]
  } );
  $('#isolate_individual_name').autocomplete source: $('#isolate_individual_name').data('autocomplete-source')