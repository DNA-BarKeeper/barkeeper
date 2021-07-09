jQuery ->
  $(document).on 'ready page:change', ->
    $('.btn-warning').tooltip()
    return