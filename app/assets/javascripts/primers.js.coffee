# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
  $('#primers').DataTable( {
    "order": [ 4, 'desc' ]
    "columnDefs": [
      { "orderable": false, "targets": 5 }
    ]
  } );

  $('#primer_project_ids').chosen({
    allow_single_deselect: true
    no_results_text: 'No results matched'
  });
