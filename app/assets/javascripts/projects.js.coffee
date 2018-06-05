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

$ ->
  noneSelected = ->
    no_species_selected = !$('#species_id option:selected').length
    no_family_selected = !$('#family_id option:selected').length
    no_order_selected = !$('#order_id option:selected').length
    no_hot_selected = !$('#higherordertaxon_id option:selected').length

    no_taxa_selected = no_species_selected && no_family_selected && no_order_selected && no_hot_selected
    no_project_selected = !$('#project_id option:selected').length

    return no_taxa_selected && no_project_selected

  showNoneCheckedMsg = ->
    message = document.createTextNode('Please check at least one contact')
    document.querySelector('.error').appendChild message
    return

$("input:submit").click (event) ->
  if noneSelected()
    event.preventDefault()
    showNoneCheckedMsg()
  return