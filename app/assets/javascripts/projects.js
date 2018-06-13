jQuery(function() {
    $('#species_id').multiselect({
        maxHeight: 200,
        includeSelectAllOption: true,
        onChange: function() {
            changeSubmitButtonStatus();
        },
        onSelectAll: function () {
            changeSubmitButtonStatus();
        },
        onDeselectAll: function () {
            changeSubmitButtonStatus();
        }
    });

    $('#family_id').multiselect({
        maxHeight: 200,
        onChange: function() {
            changeSubmitButtonStatus();
        }
    });

    $('#order_id').multiselect({
        maxHeight: 200,
        onChange: function() {
            changeSubmitButtonStatus();
        }
    });

    $('#higherordertaxon_id').multiselect({
        maxHeight: 200,
        onChange: function() {
            changeSubmitButtonStatus();
        }
    });

    $('#project_id').multiselect({
        maxHeight: 200,
        onChange: function() {
            changeSubmitButtonStatus();
        }
    });

    disableButton($("input:submit")); // Submit button is disabled on page load
});

function noneSelected() {
    var no_species_selected = !$('#species_id option:selected').length;
    var no_family_selected = !$('#family_id option:selected').length;
    var no_order_selected = !$('#order_id option:selected').length;
    var no_hot_selected = !$('#higherordertaxon_id option:selected').length;

    var no_taxa_selected = no_species_selected && no_family_selected && no_order_selected && no_hot_selected;
    var no_project_selected = !$('#project_id option:selected').length;

    return no_taxa_selected || no_project_selected;
}

function changeSubmitButtonStatus() {
    var button = $("input:submit");

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

function disableButton() {
    var button = $("input:submit")
    button.attr('disabled', 'disabled');
    button.attr('title', 'Please select at least one taxon and one project.');
}