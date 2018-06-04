jQuery ->
  $(document).ready ->
    $('#species_id').multiselect
      maxHeight: 200
      includeSelectAllOption: true

    $('#family_id').multiselect
      maxHeight: 200

    $('#order_id').multiselect
      maxHeight: 200

    $('#higherordertaxon_id').multiselect
      maxHeight: 200

    $('#project_id').multiselect
      maxHeight: 200
  return
return