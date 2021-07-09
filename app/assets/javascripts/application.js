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
