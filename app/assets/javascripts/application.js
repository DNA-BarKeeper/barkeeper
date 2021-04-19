//= require jquery
//= require jquery-ui
//= require jquery_ujs
//= require dataTables/jquery.dataTables
//= require dataTables/extras/dataTables.scroller
//= require nested_form_fields
//= require jquery.autosize
//= require jquery-fileupload/basic
//= require jquery-fileupload/vendor/tmpl
//= require chosen.jquery
//= require bootstrap
//= require keyboard_shortcuts
//= require d3.min
//= require bootstrap-multiselect
//= require_tree .


// Make datatables warning more meaningful
$.fn.dataTable.ext.errMode = () => alert('An error occurred while loading the data table. Please contact an admin if the error persists.');
