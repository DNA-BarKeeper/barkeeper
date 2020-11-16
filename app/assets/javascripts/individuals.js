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
    $('#individuals').DataTable({
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#individuals').data('source'),
        "columnDefs": [
            { "orderable": false, "targets": 6 }
        ],
        "order": [5, 'desc']
    });

    $('#individual_project_ids').chosen({
        allow_single_deselect: true,
        no_results_text: 'No results matched'
    });

    $('#individual_species_name').autocomplete({
        source: $('#individual_species_name').data('autocomplete-source')
    });

    $('#individual_collected').datepicker({
        dateFormat: 'yy-mm-dd'
    });
});
