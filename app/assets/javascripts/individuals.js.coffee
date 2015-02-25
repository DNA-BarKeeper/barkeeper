# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
  $('#individuals').DataTable( {
    bProcessing: true
    bServerSide: true
    sAjaxSource: $('#individuals').data('source')
    "columnDefs": [
      { "orderable": false, "targets": 1 }
      { "orderable": false, "targets": 6 }
    ],
    "order": [ 5, 'desc' ]
  } );
  $('#individual_species_name').autocomplete source: $('#individual_species_name').data('autocomplete-source')