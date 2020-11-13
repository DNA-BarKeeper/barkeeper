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
    $('#ngs_runs').dataTable({
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#ngs_runs').data('source'),
        "columnDefs": [{
            "targets": 2,
            "orderable": false
        }],
        "order": [1, 'desc']
    });

    $('#ngs_run_results').dataTable({
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#ngs_run_results').data('source'),
        "sScrollY": document.body.clientHeight * 70 / 100,
        "scrollX": true,
        scroller: {
            loadingIndicator: true,
            displayBuffer: 2
        },
        deferRender:    true,
        "columnDefs": [{
            "targets": 3,
            "orderable": false
        }],
        "order": [0, 'desc']
    });

    // Make file input multiple if package map was selected/uploaded
    var set_tag_map = $('#ngs_run_set_tag_map');
    var tag_primer_map = $("#ngs_run_tag_primer_map");

    if(set_tag_map.val() || $('#ngs_run_delete_set_tag_map').length) { // Package Map is selected or was uploaded before
        tag_primer_map.attr('multiple','multiple')
    }
    else {
        tag_primer_map.removeAttr('multiple')
    }

    set_tag_map.change(function() {
        if($(this).val()) {
            tag_primer_map.attr('multiple','multiple')
        }
        else {
            tag_primer_map.removeAttr('multiple');
            tag_primer_map.val("");
        }
    });
});