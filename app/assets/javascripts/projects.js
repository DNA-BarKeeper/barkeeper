/*
 * Barcode Workflow Manager - A web framework to assemble, analyze and manage DNA
 * barcode data and metadata.
 * Copyright (C) 2020 Kai Müller <kaimueller@uni-muenster.de>, Sarah Wiechers
 * <sarah.wiechers@uni-muenster.de>
 *
 * This file is part of Barcode Workflow Manager.
 *
 * Barcode Workflow Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * Barcode Workflow Manager is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with Barcode Workflow Manager.  If not, see
 * <http://www.gnu.org/licenses/>.
 */

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
