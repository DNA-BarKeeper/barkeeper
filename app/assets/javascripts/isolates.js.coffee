jQuery ->
  # Jump to correct nav tab
  hash = window.location.hash
  $('.nav-tabs a[href="' + hash + '"]').tab('show');