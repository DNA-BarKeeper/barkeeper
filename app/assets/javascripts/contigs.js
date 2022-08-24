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
    // do for all div with class partial_con
    $('.single-page-button').click(function () {
        $('button.first-page-button').attr("disabled", true);
        $('button.last-page-button').attr("disabled", true);
        $('button.next-page-button').attr("disabled", true);
        $('button.previous-page-button').attr("disabled", true);

        let partial_con_container_id = $(this).closest('table').find('.partial_con').attr("id");
        let page = 0;

        draw_as_single_page(partial_con_container_id, page);

        $('button.single-page-button').hide();
    });

    $('.go-to-button-partial-con').click( function () {
        var partial_con_container_id = $(this).closest('table').find('.partial_con').attr("id");
        var partial_con_go_to = $(this).closest('table').find('.go-to-pos').val();

        draw_position(partial_con_container_id, partial_con_go_to);
    });

    $('.first-page-button').click(function () {

        var partial_con_container_id = $(this).closest('table').find('.partial_con').attr("id");
        var page = 0;

        draw_page(partial_con_container_id, page);
    });

    $('.last-page-button').click(function () {

        var partial_con_container_id = $(this).closest('table').find('.partial_con').attr("id");
        var page = 1000;

        draw_page(partial_con_container_id, page);
    });

    $('.next-page-button').click(function () {
        var page = $("body").data("current_page");

        page++;

        var partial_con_container_id = $(this).closest('table').find('.partial_con').attr("id");

        draw_page(partial_con_container_id, page);
    });


    $('.previous-page-button').click(function () {

        var page=$( "body" ).data("current_page");

        page--;

        var partial_con_container_id = $(this).closest('table').find('.partial_con').attr("id");

        draw_page(partial_con_container_id, page);
    });

    //intial page = 0 when page loads:
    $('.partial_con').each(function() {

        // get partial_con_id from div.id:

        var id = $(this).attr("id");
        var page = 0;

        draw_page(id, page);

    });

    $(".hide_primer_read").click(function() {
        let id = $(this).data('divId');
        $(id).hide();
    });

    $(".show_primer_read").click(function() {
        let id = $(this).data('divId');
        $(id).show();
    });

    $(".move_up").click(function() {
        let id = $(this).data('divId');
        let element = $(id + "_contig");
        let group = $(id + "_group");
        let prev_group = $('#' + element.prev().attr("id").replace("contig", "group"));

        let diff = 58; // Height of a read
        let translate_y = 0;
        let translate_y_prev = 0;

        if (prev_group.offset()) {
            element.insertBefore(element.prev()).hide().show(300, 'linear');

            if (group.attr("transform")) {
                let string = group.attr("transform");
                translate_y = parseInt(string.substring(string.indexOf("(")+1, string.indexOf(")")).split(",")[1]);
            }

            if (prev_group.attr("transform")) {
                let string_prev = prev_group.attr("transform");
                translate_y_prev = parseInt(string_prev.substring(string_prev.indexOf("(")+1, string_prev.indexOf(")")).split(",")[1]);
            }

            group.attr("transform", `translate(0, ${translate_y - diff})`);
            prev_group.attr("transform", `translate(0, ${translate_y_prev + diff})`);
        }
    });

    $(".move_down").click(function() {
        let id = $(this).data('divId');
        let element = $(id + "_contig");
        let group = $(id + "_group");
        let next_group = $('#' + element.next().attr("id").replace("contig", "group"));

        let diff = 58; // Height of a read
        let translate_y = 0;
        let translate_y_next = 0;

        if (element.next().attr("id") != "consensus") { // Do not move consensus sequence
            element.insertAfter(element.next()).hide().show(300, 'linear');

            if (group.attr("transform")) {
                let string = group.attr("transform");
                translate_y = parseInt(string.substring(string.indexOf("(")+1, string.indexOf(")")).split(",")[1]);
            }

            if (next_group.attr("transform")) {
                let string_next = next_group.attr("transform");
                translate_y_next = parseInt(string_next.substring(string_next.indexOf("(")+1, string_next.indexOf(")")).split(",")[1]);
            }

            group.attr("transform", `translate(0, ${translate_y + diff})`);
            next_group.attr("transform", `translate(0, ${translate_y_next - diff})`);
        }
    });

    $(".dropbtn").click(function() {
        let id = $(this).data('divId');
        let dropdown = $(id + "_dropdown");
        let visible = dropdown.is(":visible"); // Has to be stored here to toggle correct state

        $('.dropdown-content').hide(); // Hide all dropdowns

        if (visible) {
            dropdown.hide();
        }
        else {
            dropdown.show();
        }
    });
});

// Hide all dropdowns if user clicks anywhere but on a dropdown button
$(document).click(function(e) {
    if (!(e.target.matches('.dropbtn') || e.target.matches('.glyphicon-info-sign'))) {
        $('.dropdown-content').hide();
    }
});

function draw_as_single_page(id, page){
    // var id = $(this).attr("id");

    // get id without "p-..."
    var partial_con_id = id.substr(2);

    var container_name='#'+id;

    var mm_container = $(container_name);

    if (mm_container.length > 0) {

        var contig_drawing_width = null; //set to sth way beyond expected max width; will be corrected to actual needed width by draw_partial_con
        var width_in_bases= 100000; //set to sth way beyond expected max width; will be corrected to actual max width by to_json_for_page(page, width_in_bases)  in partial_con

        var url='/partial_cons/'+partial_con_id+'/'+page+'/'+width_in_bases;

        $.ajax({
            type: "GET",
            contentType: "application/json; charset=utf-8",
            url: url,
            dataType: 'json',
            success: function (data) {
                mm_container.empty();

                draw_partial_con(data, container_name, contig_drawing_width);
                $( "body" ).data("current_page", data.page);
            },
            error: function (result) {
                alert("no data");
            }
        });
    }
}

function draw_page(id, page){
    // var id = $(this).attr("id");

    // get id without "p-..."
    var partial_con_id = id.substr(2);

    var container_name='#' + id;

    var mm_container = $(container_name);

    if (mm_container.length > 0) {

        var contig_drawing_width = $('#contig-drawing').width();
        var width_in_bases = Math.floor( (contig_drawing_width - 20)/10 ); // Adjust for scroll bar

        var url='/partial_cons/'+partial_con_id+'/'+page+'/'+width_in_bases;

        $.ajax({
            type: "GET",
            contentType: "application/json; charset=utf-8",
            url: url,
            dataType: 'json',
            success: function (data) {
                mm_container.empty();
                draw_partial_con(data, container_name, contig_drawing_width);
                $( "body" ).data("current_page", data.page);
            },
            error: function (result) {
                alert("no data");
            }
        });
    }
}

function draw_position(id, position) {
    // var id = $(this).attr("id");

    // get id without "p-..."
    var partial_con_id = id.substr(2);

    var container_name='#'+id;

    var mm_container = $(container_name);

    if (mm_container.length > 0) {

        var contig_drawing_width = $('#contig-drawing').width();
        var width_in_bases= Math.floor( contig_drawing_width/10 );

        var url='/partial_cons_pos/'+partial_con_id+'/'+position+'/'+width_in_bases;

        $.ajax({
            type: "GET",
            contentType: "application/json; charset=utf-8",
            url: url,
            dataType: 'json',
            success: function (data) {
                mm_container.empty();
                draw_partial_con(data, container_name, contig_drawing_width);
                $( "body" ).data("current_position", data.position);
            },
            error: function (result) {
                alert("no data");
            }
        });
    }
}

function draw_partial_con(partial_contig, container_name, contig_drawing_width){
//    compute height:

//    pixel per read:
//        20 for read
//        20 for qualities
//        40 for traces
//
//        additional pixel per partial:
//        20 for gap between reads & consensus
//        20 for consensus
//        20 for consensus_qualities
//        20 for coordinates

    var h = partial_contig.primer_reads.length*80+85;

    // when single page drawing requested (and, thus, requested drawing width [=viewport width] set to null), compute actually needed width:
    if (contig_drawing_width === null) {
        var primer_read = partial_contig.primer_reads[0];

        if (primer_read && primer_read.aligned_seq) {
            contig_drawing_width = primer_read.aligned_seq.length*10 + 40; // Add 40 to adjust for scroll bar
        }
        else if (partial_contig.aligned_sequence) {
            contig_drawing_width = partial_contig.aligned_sequence.length*10 + 40; // Add 40 to adjust for scroll bar
        }
        else {
            contig_drawing_width = 100000;
        }
    }

    var svg = d3.select(container_name)
        .append('svg')
        .attr('width', contig_drawing_width - 20) // Substract 20 pixel to adjust for scroll bar in page mode
        .attr('height', h)
        .attr('id', 'svg_contig');
    var x = 0;
    var y = 20;

    var color = 'gray';
    var font_family = "sans-serif";
    var font_size = "7px";


    // Get IDs from sequence divs here to draw sequence SVGs in correct order
    var ids = $('#partial-con .read-div').map(function(){
        return parseInt($(this).attr('id').match(/.+_(\d+)_.+/)[1]);
    }).get();

    // Sort reads by current order of IDs
    var used_reads = partial_contig.primer_reads.sort(function(a, b){
        return ids.indexOf(a.id) - ids.indexOf(b.id);
    });


    // For each read to show in assembly:
    for (var used_read_index=0; used_read_index < used_reads.length; used_read_index++) {

        var used_read = used_reads[used_read_index];

        // Create nested group necessary for reordering
        var read_group = svg
            .append('g')
            .style("transition", "transform 0.4s")
            .attr("transform", "translate(0,0)")
            .attr('id', "primer_read_" + used_read.id + "_group");

        var seq1 = null;
        if (used_read.aligned_seq){
            seq1 = used_read.aligned_seq;
        }
        else if (used_read.trimmed_seq){
            seq1 = used_read.trimmed_seq;
        }
        else {
            seq1 = used_read.sequence;
        }

        var aligned_peak_indices = null;
        if (used_read.aligned_peak_indices){
            aligned_peak_indices=used_read.aligned_peak_indices;
        }

        x=0;

        //trace row:
        color = 'gray';
        font_size = "7px";

        //draw traces

        //NEW:
        var atrace_line_data = [];
        var ctrace_line_data = [];
        var gtrace_line_data = [];
        var ttrace_line_data = [];


        //for each "alignment/contig" position:

        for (var aligned_peak_index=0; aligned_peak_index< aligned_peak_indices.length; aligned_peak_index++){


            x=10*aligned_peak_index-5; // -5 to accommodate "middle" text-anchor for associated text

            var current_peak = aligned_peak_indices[aligned_peak_index];


            // get scaling factor to force trace over a current basecall onto width of base letter in alignment:

            //get next peak by jumping over -1 (=alignement gaps, no sequence/trace info for that position):
            var next_index=aligned_peak_index+1;

            var next_peak = aligned_peak_indices[next_index];

            while (aligned_peak_indices[next_index] === -1) {

                next_index++;

                if (aligned_peak_indices[next_index] === undefined) {
                    next_peak = current_peak;
                } else {
                    next_peak = aligned_peak_indices[next_index];
                }
            }

            // get previous peak:
            var previous_index=aligned_peak_index-1;

            var previous_peak = aligned_peak_indices[previous_index];

            while (aligned_peak_indices[previous_index] === -1) {

                // x -= 10;

                previous_index--;

                if (aligned_peak_indices[previous_index] === undefined) {
                    previous_peak = current_peak;
                } else {
                    previous_peak = aligned_peak_indices[previous_index];
                }
            }


            //  compute distance to previous peak -
            var first_position, dist = null;
            dist = current_peak - previous_peak;
            first_position = current_peak - Math.round(dist / 2);

            //  compute distance to next peak -
            var second_position = null;
            dist = next_peak - current_peak;
            second_position = current_peak + Math.round(dist / 2);


            //fig out actual scaling factor first:
            var xscale = 10.0 / (second_position - first_position); //10 = width of basecall over which trace segment to be aligned

            var trace_ymax=50;
            var yscale=40;

            var scaled_y=y;

            //draw trace-segments for each base-call:

            var ctr=0;
            for (var xt=first_position; xt < second_position+1; xt++) {

                if (used_read.traces[xt.toString()] !== undefined ) {

                    var scaled_x=0;
                    if (x > 0) {
                        scaled_x = x + (xscale * ctr);
                    }

                    //A
                    var a_y = used_read.traces[xt.toString()].ay;
                    scaled_y=y-30+(trace_ymax-(a_y/yscale));
                    var coordinates= { "x": scaled_x,   "y": scaled_y};
                    atrace_line_data.push(coordinates);

                    //C
                    var c_y = used_read.traces[xt.toString()].cy;
                    scaled_y=y-30+(trace_ymax-(c_y/yscale));
                    coordinates= { "x": scaled_x,   "y": scaled_y};
                    ctrace_line_data.push(coordinates);

                    //G
                    var g_y = used_read.traces[xt.toString()].gy;
                    scaled_y=y-30+(trace_ymax-(g_y/yscale));
                    coordinates= { "x": scaled_x,   "y": scaled_y};
                    gtrace_line_data.push(coordinates);

                    //T
                    var t_y = used_read.traces[xt.toString()].ty;
                    scaled_y=y-30+(trace_ymax-(t_y/yscale));
                    coordinates= { "x": scaled_x,   "y": scaled_y};
                    ttrace_line_data.push(coordinates);

                }
                ctr++;
            }

        }

        var lineFunction = d3.line()
            .x(function(d) { return d.x; })
            .y(function(d) { return d.y; });

        //draw line SVG Path for all visible alignment positions simultaneously:
        read_group.append("path")
            .attr("d", lineFunction(atrace_line_data))
            .attr("stroke", "green")
            .attr("stroke-width", 0.5)
            .attr("fill", "none");
        read_group.append("path")
            .attr("d", lineFunction(ctrace_line_data))
            .attr("stroke", "blue")
            .attr("stroke-width", 0.5)
            .attr("fill", "none");
        read_group.append("path")
            .attr("d", lineFunction(gtrace_line_data))
            .attr("stroke", "orange")
            .attr("stroke-width", 0.5)
            .attr("fill", "none");
        read_group.append("path")
            .attr("d", lineFunction(ttrace_line_data))
            .attr("stroke", "red")
            .attr("stroke-width", 0.5)
            .attr("fill", "none");


        y=y+20;
        x=0;


        // //qualities row:
        //
        // color = 'gray';
        // font_size = "5px";
        //
        // for (var q=0; q< qual1.length; q++){
        //
        //     var ch= qual1[q];
        //     x=x+10;
        //
        //     if (qual1[q]>-1){
        //
        //         svg.append("text")
        //             .attr("x", x)
        //             .attr("y", y)
        //             .text(ch)
        //             .attr("font-family", font_family)
        //             .attr("font-size", font_size)
        //             .attr("fill", color)
        //             .attr("text-anchor", 'middle');
        //     }
        // }

        y=y+18;
        //font_size = "10px";

        //sequence row:
        x=0;
        color = 'black';

        font_size = '10px';

        for (var s=0; s< seq1.length; s++){

            var ch= seq1[s];

            if (ch == 'A') {
                color = '#5AE45D';
            } else if (ch == 'C') {
                color = '#5A5AE6';
            } else if (ch == 'G') {
                color = '#E2E65A';
            } else if (ch == 'T') {
                color = '#E65A5A';
            } else {
                color = 'lightgray';
            }

            x=x+10;

            read_group.append('rect')
                .attr("x", x - 5)
                .attr("y", y - 11)
                .attr("width", 10)
                .attr("height", 14)
                .attr("fill", color);

            read_group.append("text")
                .attr("x", x)
                .attr("y", y)
                .text(ch)
                .attr("font-family", "sans-serif")
                .attr("font-size", font_size)
                .attr("fill", "black")
                .attr("text-anchor", 'middle')
                .attr("id", used_read.id + "-" + used_read.original_positions[s])
                .style("cursor", "crosshair")
                .on('click', function () {
                    var coordinates = d3.select(this).attr("id").split("-");
                    var read_id = coordinates[0];
                    var position = coordinates[1]

                    // Show div with primer read view and jump to it
                    $('#primer_read_' + read_id + '_view').show();
                    window.location = '#read_view_' + read_id;

                    scroll_with_highlight(position, read_id);
                });
        }

        y=y+20;

        // End for through used_reads:
    }

    // render aligned consensus sequence:
    if (partial_contig.aligned_sequence != null) {

        x=0;
        y+=40;

        //sequence row:

        color = 'lightgray';
        font_size = '10px';

        for (s=0; s< partial_contig.aligned_sequence.length; s++){
            ch= partial_contig.aligned_sequence[s];
            if (ch == 'A') {
                color = '#5AE45D';
            } else if (ch == 'C') {
                color = '#5A5AE6';
            } else if (ch == 'G') {
                color = '#E2E65A';
            } else if (ch == 'T') {
                color = '#E65A5A';
            } else {
                color = 'lightgray';
            }

            x=x+10;

            svg.append('rect')
                .attr("x", x - 5)
                .attr("y", y - 11)
                .attr("width", 10)
                .attr("height", 14)
                .attr("fill", color);

            svg.append("text")
                .attr("x", x)
                .attr("y", y)
                .text(ch)
                .attr("font-family", "sans-serif")
                .attr("font-size", font_size)
                .attr("font-weight", "bold")
                .attr("fill", "black")
                .attr("text-anchor", 'middle');
        }
        y+=10;

        x=0;

        // coordinates - position indicator

        color = 'gray';
        font_size = '10px';

        for (var c=partial_contig.start_pos; c < partial_contig.end_pos; c++) {
            var disp = c + 1;

            if (disp % 10 == 0) {

                svg.append("text")
                    .attr("x", x+10)
                    .attr("y", y)
                    .text('.')
                    .attr("font-family", "sans-serif")
                    .attr("font-size", "7px")
                    .attr("fill", color)
                    .attr("text-anchor", 'middle');
                svg.append("text")
                    .attr("x", x+10)
                    .attr("y", y+12)
                    .text(disp)
                    .attr("font-family", "sans-serif")
                    .attr("font-size", font_size)
                    .attr("fill", color)
                    .attr("text-anchor", 'middle');

            }
            x+=10;
        }

        y+=20;

    }
}

//  keyboard shortcuts:

shortcut.add("Right", function() {
    next_page();
},{
    'disable_in_input':true
});
shortcut.add("Left", function() {
    previous_page();
},{
    'disable_in_input':true
});
shortcut.add("Shift+Left", function() {
    first_page();
},{
    'disable_in_input':true
});
shortcut.add("Shift+Right", function() {
    last_page();
},{
    'disable_in_input':true
});

function next_page() {
    $('.next-page-button').first().click();
}
function previous_page() {
    $('.previous-page-button').first().click();
}
function first_page() {
    $('.first-page-button').first().click();
}
function last_page() {
    $('.last-page-button').first().click();
}