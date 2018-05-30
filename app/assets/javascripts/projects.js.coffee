jQuery ->
  $(document).ready ->
    $('#taxa_id').multiselect
      maxHeight: 200
      enableClickableOptGroups: true
      enableCollapsibleOptGroups: true

    $('#project_id').multiselect
      maxHeight: 200
  return
return