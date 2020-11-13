###
Barcode Workflow Manager - A web framework to assemble, analyze and manage DNA
barcode data and metadata.
Copyright (C) 2020 Kai Müller <kaimueller@uni-muenster.de>, Sarah Wiechers
<sarah.wiechers@uni-muenster.de>

This file is part of Barcode Workflow Manager.

Barcode Workflow Manager is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

Barcode Workflow Manager is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with Barcode Workflow Manager.  If not, see
<http://www.gnu.org/licenses/>.
###
# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
  $('#species').DataTable( {
    bProcessing: true
    bServerSide: true
    sAjaxSource: $('#species').data('source')
    "columnDefs": [
      { "orderable": false, "targets": 4 }
    ],
    "order": [ 3, 'desc' ]
  } );

  $('#species_family_name').autocomplete
    source: $('#species_family_name').data('autocomplete-source')

  $('#wiki').width($(document).width()).height($(document).height())

  $('#species_project_ids').chosen({
    allow_single_deselect: true
    no_results_text: 'No results matched'
  });
