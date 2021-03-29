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

    disableButton($('input[type="submit"][value="Associate taxa"]')); // Submit button is disabled on page load
});

function noneSelected() {
    var no_taxon_selected = document.getElementById("associated_taxon").value === '';
    var no_project_selected = !$('#project_id option:selected').length;

    return no_taxon_selected || no_project_selected;
}

function changeSubmitButtonStatus() {
    var button = $('input[type="submit"][value="Associate taxa"]');

    if (noneSelected()) {
        disableButton(button);
    }
    else {
        enableButton(button);
    }
}

function enableButton(button) {
    button.removeAttr('disabled');
    button.removeAttr('title');
}

function disableButton(button) {
    button.attr('disabled', 'disabled');
    button.attr('title', 'Please select at least one project and one taxon.');
}