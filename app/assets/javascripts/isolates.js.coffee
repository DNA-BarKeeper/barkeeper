# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
  $('#isolates').DataTable( {
    bProcessing: true
    bServerSide: true
    sAjaxSource: $('#isolates').data('source')
    "columnDefs": [
      { "orderable": false, "targets": 1 }
      { "orderable": false, "targets": 2 }
      { "orderable": false, "targets": 4 }
    ]
    "order": [ 3, 'desc' ]
  } );
  $('#isolate_individual_name').autocomplete source: $('#isolate_individual_name').data('autocomplete-source')