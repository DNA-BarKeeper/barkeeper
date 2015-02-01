# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery -> $('#gen_family_name').autocomplete source: $('#gen_family_name').data('autocomplete-source')