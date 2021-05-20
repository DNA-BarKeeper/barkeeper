jQuery(function() {
    $('#query_associated_taxon').on('select2:select', function (e) {
        changeSubmitButtonStatus();
    });
    $('#associated_project_ids').on('select2:select', function (e) {
        changeSubmitButtonStatus();
    });

    // $('#query_associated_taxon').on('select2:select', changeSubmitButtonStatus());
    // $('#associated_project_ids').on('select2:select', changeSubmitButtonStatus());

    // Submit button is disabled on page load
    disableButton($('input[type="submit"][value="Associate taxa"]'), 'Please select at least one project and one taxon.');
});

function noneSelected() {
    var no_taxon_selected = true;
    var no_project_selected = true;

    if ($('#associated_project_ids').hasClass("select2-hidden-accessible")) {
        no_taxon_selected = $('#query_associated_taxon').select2('data')[0].text == '';
        no_project_selected = !$('#associated_project_ids').select2('data').length;
    }

    return no_taxon_selected || no_project_selected;
}

function changeSubmitButtonStatus() {
    console.log(noneSelected());

    var button = $('input[type="submit"][value="Associate taxa"]');

    if (noneSelected()) {
        disableButton(button, 'Please select at least one project and one taxon.');
    }
    else {
        enableButton(button);
    }
}
