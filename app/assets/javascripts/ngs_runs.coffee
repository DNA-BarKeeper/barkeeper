# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
  $('#ngs_runs').DataTable( {
    bProcessing: true
    bServerSide: true
    sAjaxSource: $('#ngs_runs').data('source')
    "columnDefs": [
      { "orderable": false, "targets": 2 }
    ]
    "order": [ 1, 'desc' ]
  } );
