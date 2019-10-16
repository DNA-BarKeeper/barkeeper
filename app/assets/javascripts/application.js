//= require jquery
//= require jquery-ui
//= require jquery_ujs
// require turbolinks
//= require dataTables/jquery.dataTables
//= require best_in_place
//= require best_in_place.jquery-ui
//= require jquery.autosize
//= require jquery-fileupload/basic
//= require jquery-fileupload/vendor/tmpl
//= require chosen.jquery
//= require jquery.turbolinks
//= require bootstrap
//= require keyboard_shortcuts
//= require d3.min
//= require bootstrap-multiselect
//= require_tree .

// Make datatables warning more meaningful
$.fn.dataTable.ext.errMode = () => alert('An error occurred while loading the table data. Please contact an admin if the error persists.');

$(document).ready(function() {
    /* Activating Best In Place */
    jQuery(".best_in_place").best_in_place();
});