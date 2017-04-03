$(document).on('page:fetch', function() {
    $('.sk-circle').show();
});
$(document).on('page:change', function() {
    $('.sk-circle').hide();
});


jQuery(function() {

    var $loading2= $('.sk-circle.trace-loading').hide();
    var $buttons = $('#buttons').hide();

    $(document)
        .ajaxStart(function () {
            $loading2.show();
        })
        .ajaxStop(function () {
            $loading2.hide();
            $buttons.show();
        });


    $('#contigs').DataTable({
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#contigs').data('source'),
        "columnDefs": [
            { "orderable": false, "targets": 1 },
            { "orderable": false, "targets": 4 }
        ],
        "order": [ 3, 'desc' ]
    });

    $('#contigs-duplicates').DataTable({
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#contigs-duplicates').data('source'),
        "columnDefs": [
            { "orderable": false, "targets": 1 },
            { "orderable": false, "targets": 4 }
        ],
        "order": [ 0, 'asc' ]
    });


    $('#contig_isolate_name').autocomplete({
        source: $('#contig_isolate_name').data('autocomplete-source')
    });
    $('#contig_marker_sequence_name').autocomplete({
        source: $('#contig_marker_sequence_name').data('autocomplete-source')
    });

    // do for all div with class partial_con

    $('.single-page-button').click(function () {

        //todo: rm all other buttons for page navigation

        var partial_con_container_id = $(this).closest('table').find('.partial_con').attr("id");
        var page=0;

        draw_as_single_page(partial_con_container_id, page);
    });

    $('.go-to-button-partial-con').click( function () {

        var partial_con_container_id = $(this).closest('table').find('.partial_con').attr("id");
        var partial_con_go_to =$(this).closest('table').find('.go-to-pos').val();

        draw_position(partial_con_container_id, partial_con_go_to);
    });

    $('.first-page-button').click(function () {

        var partial_con_container_id = $(this).closest('table').find('.partial_con').attr("id");
        var page=0;

        draw_page(partial_con_container_id, page);
    });

    $('.last-page-button').click(function () {

        var partial_con_container_id = $(this).closest('table').find('.partial_con').attr("id");
        var page=1000;

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
        var page=0;

        draw_page(id, page);

    });

});

function draw_as_single_page(id, page){
    // var id = $(this).attr("id");

    // get id without "p-..."
    var partial_con_id = id.substr(2);

    var container_name='#'+id;

    var mm_container = $(container_name);

    if (mm_container.length > 0) {

        var contig_drawing_width = null; //set to sth way beyonad expected max width; will be corrected to actual needed width by draw_partial_con
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

    var container_name='#'+id;

    var mm_container = $(container_name);

    if (mm_container.length > 0) {

        var contig_drawing_width = $('#contig-drawing').width();
        var width_in_bases= Math.floor( contig_drawing_width/10 );

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

function draw_position(id, position){
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

    var h=partial_contig.primer_reads.length*80+80;

    // when single page drawing requested (and, thus, requested drawing width [=viewport width] set to null), compute actually needed width:
    if (contig_drawing_width===null){
        var primer_read = partial_contig.primer_reads[0];
        if (primer_read.aligned_seq){
            contig_drawing_width=primer_read.aligned_seq.length*10;
        } else {
            contig_drawing_width=100000;
        }
    }

    var svg=d3.select(container_name)
        .append('svg')
        .attr('width', contig_drawing_width)
        .attr('height', h);
    var x=0;
    var y=20;

    var color = 'gray';
    var font_family = "sans-serif";
    var font_size = "7px";


    var used_reads = partial_contig.primer_reads;


    function all_zero(trace_segment) {

        for (var i = 0; i < trace_segment.length; i++) {

            if (trace_segment[i] !== 0) {
                return false;
            }
        }
        return true;
    }

    for (var used_read_index=0; used_read_index < used_reads.length; used_read_index++){
        var used_read= used_reads[used_read_index];

        var seq1 = null;
        if (used_read.aligned_seq){
            seq1=used_read.aligned_seq;
        } else if (used_read.trimmed_seq){
            seq1=used_read.trimmed_seq;
        } else {
            seq1=used_read.sequence;
        }

        var qual1= null;
        if (used_read.aligned_qualities){
            qual1=used_read.aligned_qualities;
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

                //TODO: fix that offset correction, doesn't make sense:
                // correction: traces somehow offset otherwise:
                x -= 10;

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

            var scaled_line_function = d3.svg.line()
                .x(function(d,i) {
                        if (x > 0) {
                            return x + (xscale * i);
                        } else {
                            return 0;
                        }
                    }
                )
                .y(function(d) { return y-40+(trace_ymax-(d/yscale)); })
                .interpolate("linear");

            //draw trace-segments for each base-call:

            //A
            //extract segment from trace:
            var atrace_segment = [];

            for (var xt=first_position; xt < second_position+1; xt++) {

                if (used_read.traces[xt.toString()] !== undefined ) {
                    var a_y = used_read.traces[xt.toString()].ay;
                    atrace_segment.push(a_y);
                    // atrace_segment.push(used_read.traces[xt.toString()].ay);
                }
            }
            if (atrace_segment.length !== 0 && !all_zero(atrace_segment)) {
                svg.append("path")
                    .attr("d", scaled_line_function(atrace_segment))
                    .attr("stroke", "green")
                    .attr("stroke-width", 0.5)
                    .attr("fill", "none")
                    .attr("text-anchor", 'middle');
            }

            //C
            var ctrace_segment = [];

            for ( xt=first_position; xt < second_position+1; xt++){
                if (used_read.traces[xt.toString()] !== undefined ) {
                    var c_y = used_read.traces[xt.toString()].cy;
                    ctrace_segment.push(c_y);
                }
            }
            if (ctrace_segment.length !==0 && !all_zero(ctrace_segment)) {
                svg.append("path")
                    .attr("d", scaled_line_function(ctrace_segment))
                    .attr("stroke", "blue")
                    .attr("stroke-width", 0.5)
                    .attr("fill", "none")
                    .attr("text-anchor", 'middle');
            }

            //G
            var gtrace_segment = [];

            for ( xt=first_position; xt < second_position+1; xt++){
                if (used_read.traces[xt.toString()] !== undefined ) {
                    var g_y = used_read.traces[xt.toString()].gy;
                    gtrace_segment.push(g_y);
                }
            }
            if (gtrace_segment.length !== 0 && !all_zero(gtrace_segment)) {
                svg.append("path")
                    .attr("d", scaled_line_function(gtrace_segment))
                    .attr("stroke", "black")
                    .attr("stroke-width", 0.5)
                    .attr("fill", "none")
                    .attr("text-anchor", 'middle');
            }

            //T

            var ttrace_segment = [];

            for ( xt=first_position; xt < second_position+1; xt++){
                if (used_read.traces[xt.toString()] !== undefined ) {
                    var t_y = used_read.traces[xt.toString()].ty;
                    ttrace_segment.push(t_y);
                }
            }
            if (ttrace_segment.length !== 0 && !all_zero(ttrace_segment)) {
                svg.append("path")
                    .attr("d", scaled_line_function(ttrace_segment))
                    .attr("stroke", "red")
                    .attr("stroke-width", 0.5)
                    .attr("fill", "none")
                    .attr("text-anchor", 'middle');
            }
        }

        y=y+20;
        x=0;


        //qualities row:

        color = 'gray';
        font_size = "5px";

        for (var q=0; q< qual1.length; q++){

            var ch= qual1[q];
            x=x+10;

            if (qual1[q]>-1){

                svg.append("text")
                    .attr("x", x)
                    .attr("y", y)
                    .text(ch)
                    .attr("font-family", font_family)
                    .attr("font-size", font_size)
                    .attr("fill", color)
                    .attr("text-anchor", 'middle');
            }
        }

        y=y+20;
        //font_size = "10px";

        //sequence row:
        x=0;
        color = 'black';

        font_size = '10px';

        for (var s=0; s< seq1.length; s++){

            ch= seq1[s];

            if (ch == 'A') {
                color = 'green';
            } else if (ch == 'C') {
                color = 'blue';
            } else if (ch == 'G') {
                color = 'black';
            } else if (ch == 'T') {
                color = 'red';
            } else {
                color = 'gray';
            }

            x=x+10;

            svg.append("text")
                .attr("x", x)
                .attr("y", y)
                .text(ch)
                .attr("font-family", "sans-serif")
                .attr("font-size", font_size)
                .attr("fill", color)
                .attr("text-anchor", 'middle')
                .attr("id", used_read.id + "-" + used_read.original_positions[s])
                .style("cursor", "crosshair")
                .on('click', function () {
                    // alert(d3.select(this).attr("id"));
                    var coordinates = d3.select(this).attr("id").split("-");
                    var url='/primer_reads/'+coordinates[0]+'/edit/'+coordinates[1];
                    window.open(url, '_blank');
                });
        }

        y=y+20;

        //end for through used_reads:
    }

    // render aligned consensus sequence:
    if (partial_contig.aligned_sequence != null) {
        //qual row:
        color = 'gray';
        x=0;
        y+=20;
        font_size = '5px';

        // if (partial_contig.aligned_qualities != null) {
        //     for (s = 0; s < partial_contig.aligned_qualities.length; s++) {
        //         ch = partial_contig.aligned_qualities[s];
        //         x = x + 10;
        //         if (partial_contig.aligned_qualities[s] > -10) {
        //             d3.select('svg').append("text")
        //                 .attr("x", x)
        //                 .attr("y", y)
        //                 .text(ch)
        //                 .attr("font-family", "sans-serif")
        //                 .attr("font-size", font_size)
        //                 .attr("fill", color)
        //                 .attr("text-anchor", 'middle');
        //         }
        //     }
        // }

        x=0;
        y+=20;

        //sequence row:
        color = 'black';
        font_size = '12px';


        // svg.append("text")
        //     .attr("x", x)
        //     .attr("y", y)
        //     .text('Consensus')
        //     .attr("font-family", "sans-serif")
        //     .attr("font-size", font_size)
        //     .attr("font-weight", "bold")
        //     .attr("fill", color);

        color = 'gray';
        font_size = '10px';

        for (s=0; s< partial_contig.aligned_sequence.length; s++){
            ch= partial_contig.aligned_sequence[s];
            if (ch == 'A') {
                color = 'green';
            } else if (ch == 'C') {
                color = 'blue';
            } else if (ch == 'G') {
                color = 'black';
            } else if (ch == 'T') {
                color = 'red';
            } else {
                color = 'gray';
            }
            x=x+10;

            svg.append("text")
                .attr("x", x)
                .attr("y", y)
                .text(ch)
                .attr("font-family", "sans-serif")
                .attr("font-size", font_size)
                .attr("font-weight", "bold")
                .attr("fill", color)
                .attr("text-anchor", 'middle');
        }
        y+=10;

        x=0;

        // coordinates - position indicator

        color = 'gray';
        font_size = '7px';

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
                    .attr("y", y+10)
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