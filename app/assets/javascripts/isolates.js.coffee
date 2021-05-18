jQuery ->
  $('#isolate_project_ids').chosen({
    allow_single_deselect: true
    no_results_text: 'No results matched'
  });

  $('#isolate_individual_name').autocomplete
    source: $('#isolate_individual_name').data('autocomplete-source')

  # Jump to correct nav tab
  hash = window.location.hash
  $('.nav-tabs a[href="' + hash + '"]').tab('show');