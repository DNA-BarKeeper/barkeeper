jQuery ->
  $('#users').DataTable( {
    "columnDefs": [
      { "orderable": false, "targets": 3 }
      { "orderable": false, "targets": 7 }
    ]
  } );

  $(document).on 'ready page:change', ->
    $('.btn-warning').tooltip()
    return

  $(document).ready ->
    $('#user_default_project_id').multiselect()
    return