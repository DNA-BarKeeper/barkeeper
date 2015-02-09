# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
  $('#species').DataTable( {
    bProcessing: true
    bServerSide: true
    sAjaxSource: $('#species').data('source')
    "columnDefs": [
      { "orderable": false, "targets": 4 }
    ],
    "order": [ 3, 'desc' ]
  } );
  $('#species_family_name').autocomplete source: $('#species_family_name').data('autocomplete-source')