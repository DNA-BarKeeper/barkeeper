jQuery ->
  $(document).on 'ready page:change', ->
    $('.btn-warning').tooltip()
    return

  $(document).ready ->
    $('#user_default_project_id').multiselect()
    return