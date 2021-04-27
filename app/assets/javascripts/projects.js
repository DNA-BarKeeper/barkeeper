jQuery(function() {
    $('#associated_taxon').autocomplete({
        source: $('#associated_taxon').data('autocomplete-source')
    });

    $('#associated_taxon').change(function() {
        changeSubmitButtonStatus();
    });


    $('#project_id').multiselect({
        maxHeight: 200,
        onChange: function() {
            changeSubmitButtonStatus();
        }
    });

    // Submit button is disabled on page load
    disableButton($('input[type="submit"][value="Associate taxa"]'), 'Please select at least one project and one taxon.');
});

function noneSelected() {
    var no_taxon_selected = document.getElementById("associated_taxon").value === '';
    var no_project_selected = !$('#project_id option:selected').length;

    return no_taxon_selected || no_project_selected;
}

function changeSubmitButtonStatus() {
    var button = $('input[type="submit"][value="Associate taxa"]');

    if (noneSelected()) {
        disableButton(button, 'Please select at least one project and one taxon.');
    }
    else {
        enableButton(button);
    }
}
