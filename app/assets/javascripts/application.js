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

//= require jquery
//= require jquery-ui
//= require jquery_ujs
//= require dataTables/jquery.dataTables
//= require dataTables/extras/dataTables.scroller
//= require nested_form_fields
//= require jquery.autosize
//= require jquery-fileupload/basic
//= require jquery-fileupload/vendor/tmpl
//= require bootstrap
//= require keyboard_shortcuts
//= require d3.min
//= require select2
//= require_tree .

jQuery(function() {
    // Initially hide global spinner
    var $global_spinner = $(".sk-circle").hide();
    var $buttons = $('#buttons').hide();

    $(document)
        .ajaxStart(function () {
            $global_spinner.show();
        })
        .ajaxStop(function () {
            $global_spinner.hide();
            $buttons.show();
        });
});

// Make datatables warning more meaningful
$.fn.dataTable.ext.errMode = () => alert('An error occurred while loading the data table. Please contact an admin if the error persists.');

// Function to replace html relevant characters to prevent XSS attacks
function htmlSafe(str) {
    return String(str).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
}

function enableButton(button, message = null) {
    button.removeAttr('disabled');
    if (message) {
        button.attr('title', message);
    }
    else {
        button.removeAttr('title');
    }
}

function disableButton(button, message) {
    button.attr('disabled', 'disabled');
    button.attr('title', message);
}

// Delete previous diagram
function deleteVisualization(id) {
    d3.select(id).selectAll("svg").remove();
}
