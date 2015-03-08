$(document).on('page:fetch', function() {
    $('#page_loading').show();
});
$(document).on('page:change', function() {
    $('#page_loading').hide();
});


jQuery(function() {
    $('#contigs').DataTable({
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#contigs').data('source'),
        "columnDefs": [
            {
                "orderable": false,
                "targets": 3
            }
        ],
        "order": [ 2, 'desc' ]
    });
    $('#contig_isolate_name').autocomplete({
        source: $('#contig_isolate_name').data('autocomplete-source')
    });
    $('#contig_marker_sequence_name').autocomplete({
        source: $('#contig_marker_sequence_name').data('autocomplete-source')
    });

//    draw partial_cons

    var partial_cons = $('#contig').data('url');


    if (partial_cons){
        draw_contig(partial_cons);
    }

});

function draw_contig(partial_cons){

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
//        20 for gap between partials

    var h=partial_cons.length*80;
    for(var q = 0; q < partial_cons.length; q++) {
        h+= partial_cons[q].primer_reads.length*80;
    }

    var svg=d3.select('#contig')
        .append('svg')
        .attr('width', 15000)
        .attr('height', h-30);

    var x=0;
    var y=20;
    var block_start=300;

    var color = 'gray';
    var font_family = "sans-serif";
    var font_size = "7px";

    for(var partial_cons_index = 0; partial_cons_index < partial_cons.length; partial_cons_index++){
        var partial_contig = partial_cons[partial_cons_index];

        var used_reads = partial_contig.primer_reads;

        for (var j=0; j < used_reads.length; j++){
            var pr= used_reads[j];

            if (pr){

                var seq1 = null;
                if (pr.aligned_seq){
                    seq1=pr.aligned_seq;
                } else if (pr.trimmed_seq){
                    seq1=pr.trimmed_seq;
                } else {
                    seq1=pr.sequence;
                }
                var qual1= null;
                if (pr.aligned_qualities){
                    qual1=pr.aligned_qualities;
                } else if (pr.trimmed_quals) {
                    qual1=pr.trimmed_quals;
                } else {
                    qual1=pr.qualities;
                }
            }

            x=0;

            //trace row
            color = 'gray';
            font_size = "7px";

            x=block_start;

            //compute aligned peak_indices
            var aligned_peak_indices = [];

            var pi=pr.trimmedReadStart-2;

            for (var ai=0; ai < pr.aligned_qualities.length; ai++) {
                if (pr.aligned_qualities[ai]==-1) {
                    aligned_peak_indices.push(-1);
                } else {
                    aligned_peak_indices.push(pr.peak_indices[pi]);
                    pi++;
                }
            }

            //draw traces
            for (var i=0; i< aligned_peak_indices.length; i++){

                x=(block_start-5)+10*i; // -5 to accommodate "middle" text-anchor for associated text

                var current_peak = aligned_peak_indices[i];


                if (current_peak!=-1 && i<aligned_peak_indices.length-1)  {

                    var next_index=i+1;
                    var next_peak=aligned_peak_indices[next_index];

                    if (next_peak==-1){
                        while (aligned_peak_indices[next_index]==-1) {
                            next_index++;
                            next_peak = aligned_peak_indices[next_index];
                        }
                    }

                    var previous_index=i-1;
                    var previous_peak=aligned_peak_indices[previous_index];

                    if (previous_peak==-1){
                        while (aligned_peak_indices[previous_index]==-1) {
                            previous_index--;
                            previous_peak = aligned_peak_indices[previous_index];
                        }
                    }

                    //  compute distance to previous peak -
                    var first_position, dist = null;
                    if (i>0) {
                        dist = current_peak - previous_peak;
                        first_position = current_peak - Math.round(dist/2);
                    } else {
                        continue;
                    }

                    //  compute distance to next peak -
                    var second_position = null;
                    if (i<aligned_peak_indices.length-1) {
                        dist = next_peak - current_peak;
                        second_position = current_peak + Math.round(dist / 2);
                    } else {
                        continue;
                    }

                    if (isNaN(second_position)==false && isNaN(first_position)==false) {

                        //fig out actual scaling factor first
                        var xscale = 10.0 / (second_position - first_position); //10 = width of basecall over which trace segment to be aligned

                        var trace_ymax=50;
                        var yscale=40;

                        var scaled_line_function = d3.svg.line()
                            .x(function(d,i) { return x+(xscale*i); })
                            .y(function(d) { return y-40+(trace_ymax-(d/yscale)); })
                            .interpolate("linear");

                        //draw trace-segments for each base-call

                        //A
                        //extract segment from array
                        var atrace_segment = pr.atrace.slice(first_position, second_position+1);

                        svg.append("path")
                            .attr("d", scaled_line_function(atrace_segment))
                            .attr("stroke", "green")
                            .attr("stroke-width", 0.5)
                            .attr("fill", "none")
                            .attr("text-anchor", 'middle');
                        //C
                        //extract segment from array
                        var ctrace_segment = pr.ctrace.slice(first_position, second_position+1);
                        svg.append("path")
                            .attr("d", scaled_line_function(ctrace_segment))
                            .attr("stroke", "blue")
                            .attr("stroke-width", 0.5)
                            .attr("fill", "none")
                            .attr("text-anchor", 'middle');
                        //G
                        //extract segment from array
                        var gtrace_segment = pr.gtrace.slice(first_position, second_position+1);
                        svg.append("path")
                            .attr("d", scaled_line_function(gtrace_segment))
                            .attr("stroke", "black")
                            .attr("stroke-width", 0.5)
                            .attr("fill", "none")
                            .attr("text-anchor", 'middle');
                        //T
                        //extract segment from array
                        var ttrace_segment = pr.ttrace.slice(first_position, second_position+1);
                        svg.append("path")
                            .attr("d", scaled_line_function(ttrace_segment))
                            .attr("stroke", "red")
                            .attr("stroke-width", 0.5)
                            .attr("fill", "none")
                            .attr("text-anchor", 'middle');
                    }

                }

            }

            y=y+20;
            x=0;

            //qualities row:
            color = 'gray';
            font_size = "5px";

            x=block_start;

            for (q=0; q< qual1.length; q++){
                var ch= qual1[q];
                x=x+10;

                if (qual1[q]>-1){

                    //ctx.strokeText(ch, x, y);

                    svg.append("text")
                        .attr("x", x)
                        .attr("y", y)
                        .text(ch)
                        .attr("font-family", "sans-serif")
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
            font_size = '12px';
            var current_read_id=pr.id;

            //var read_label="pr"+pr.id;

            svg.append("text")
                .attr("x", x)
                .attr("y", y)
                .text(pr.name)
                .attr("font-family", "sans-serif")
                .attr("font-size", font_size)
                .attr("fill", color)
                .attr("cursor", "pointer")
                .attr("id", current_read_id)
                .on('mouseover', function(){
                    d3.select(this)
                        .attr('fill','#3072ed')

                })
                .on('mouseout', function(){
                    d3.select(this)
                        .attr('fill','black')
                })
                .on('click', function(){
                    var selected_primer = d3.select(this);
                    var primer_id = selected_primer.attr("id");
                    window.location.href = "http://www.gbol5.de/primer_reads/" + primer_id + "/edit";
                });

            font_size = '10px';

            x=block_start;

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
                    .append("svg:title")
                    .text((s+1)+' in '+pr.name);
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
            x=block_start;

            for (s=0; s< partial_contig.aligned_qualities.length; s++){
                ch= partial_contig.aligned_qualities[s];
                x=x+10;
                if (partial_contig.aligned_qualities[s]>-10){
                    d3.select('svg').append("text")
                        .attr("x", x)
                        .attr("y", y)
                        .text(ch)
                        .attr("font-family", "sans-serif")
                        .attr("font-size", font_size)
                        .attr("fill", color)
                        .attr("text-anchor", 'middle');
                }
            }

            x=0;
            y+=20;

            //sequence row:
            color = 'black';
            font_size = '12px';


            svg.append("text")
                .attr("x", x)
                .attr("y", y)
                .text('Consensus')
                .attr("font-family", "sans-serif")
                .attr("font-size", font_size)
                .attr("font-weight", "bold")
                .attr("fill", color);

            color = 'gray';
            font_size = '10px';

            x=block_start;

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


            // coordinates - position indicator

            color = 'gray';
            font_size = '7px';
            x=block_start;

            for (var c=0; c < partial_contig.aligned_sequence.length; c++) {
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
        y+=20;

        //end loop through partial_cons
    }
    y += 20;
}