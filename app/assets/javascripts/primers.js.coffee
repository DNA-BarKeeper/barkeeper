# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
  $('#primers').DataTable( {
    "order": [ 5, 'desc' ]
    "columnDefs": [
      { "orderable": false, "targets": 6 }
    ]
  } );
