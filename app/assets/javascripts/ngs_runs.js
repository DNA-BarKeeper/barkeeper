/*
 * BarKeeper - A versatile web framework to assemble, analyze and manage DNA
 * barcoding data and metadata.
 * Copyright (C) 2022 Kai Müller <kaimueller@uni-muenster.de>, Sarah Wiechers
 * <sarah.wiechers@uni-muenster.de>
 *
 * This file is part of BarKeeper.
 *
 * BarKeeper is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * BarKeeper is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with BarKeeper.  If not, see <http://www.gnu.org/licenses/>.
 */

jQuery(function() {
    // Make file input multiple if package map was selected/uploaded
    var set_tag_map = $('#ngs_run_set_tag_map');
    var tag_primer_map = $("#ngs_run_tag_primer_map");

    if(set_tag_map.val() || document.getElementsByClassName('remove_set_tag_map').length > 0) { // Package Map is selected or was uploaded before
        tag_primer_map.attr('multiple','multiple')
    }
    else {
        tag_primer_map.removeAttr('multiple')
    }

    set_tag_map.change(function() {
        if($(this).val() || document.getElementsByClassName('remove_set_tag_map').length > 0) {
            tag_primer_map.attr('multiple','multiple')
        }
        else {
            tag_primer_map.removeAttr('multiple');
            tag_primer_map.val("");
        }
    });
});