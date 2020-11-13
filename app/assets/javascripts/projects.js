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

    disableButton($('input[type="submit"][value="Add project(s)"]')); // Submit button is disabled on page load
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
    var button = $('input[type="submit"][value="Add project(s)"]');

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
    button.attr('title', 'Please select at least one taxon and one project.');
}