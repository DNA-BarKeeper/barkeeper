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
