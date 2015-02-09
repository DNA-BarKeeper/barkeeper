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


//    draw partial_cons

    var partial_cons = $('#contig').data('url');


    if (partial_cons){

        document.getElementById('download_as_img').addEventListener('click', function() {
            var filename= "Contig.png";
            downloadCanvas(this, 'ContigCanvas', filename); // <- this can be a dynamic name
        }, false);

        draw_contig(partial_cons);

        //clean up
        $('#loading').remove()
    }

});

function draw_contig(partial_cons){
//return console.log(contig)
//    continue here
    var canvas = document.getElementById('ContigCanvas');
    canvas.width= 30000;

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
//        20 for gap between partials
    var h=partial_cons.length*80;
    for(var q = 0; q < partial_cons.length; q++) {
        h+= partial_cons[q].primer_reads.length*80;
    }

    h*=2; // for retina scaling stuff
    canvas.height = h;
    canvas.style.width = "15000px";
    canvas.style.height = Math.round(h/2)+"px";
    xmax=15000;
    ymax=h;

    var ctx = canvas.getContext('2d');

    var r=window.devicePixelRatio;

    if (r > 1 ) {
        ctx.scale(r,r);
    }

    //  mk white background
    ctx.fillStyle = 'white';
    ctx.rect(0, 0, xmax, ymax);
    ctx.fill();

    var x=0;
    var y=20;
    var block_start=300;

    ctx.strokeStyle = 'gray';
    ctx.font = '10pt Courier New';

    for(var i = 0; i < partial_cons.length; i++){
        var partial_contig = partial_cons[i];


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
            ctx.strokeStyle = 'gray';
            ctx.font = '5pt Courier New';
//            ctx.strokeText('Traces', x, y);

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
            for (i=0; i< aligned_peak_indices.length; i++){

                x=block_start+10*i;

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

                    if (second_position!=null && first_position!=null) {
                        ctx.save();
                        ctx.translate(x, y - 40);

//                    fig out actual scaling factor first

                        var xscale = 10.0 / (second_position - first_position);

                        ctx.scale(xscale, 1);

//                      draw all four traces paths at 0,0

                        draw_trace_segment(ctx, pr, first_position, second_position);

                        ctx.restore();
                    }

                }

            }

            y=y+20;
            ctx.font = '10pt Courier New';
            x=0;

            //qualities row:
            ctx.strokeStyle = 'gray';
            ctx.font = '5pt Courier New';

            x=block_start;

            for (var q=0; q< qual1.length; q++){
                var ch= qual1[q];
                x=x+10;

                if (qual1[q]!=-1){
                    ctx.strokeText(ch, x, y);
                }
            }

            y=y+20;
            ctx.font = '10pt Courier New';

            //sequence row:
            x=0;
            ctx.strokeStyle = 'black';
            ctx.font = '8pt Arial';
            ctx.strokeText(pr.name, x, y);
            ctx.strokeStyle = 'gray';
            ctx.font = '10pt Courier New';

            x=block_start;

            for (var s=0; s< seq1.length; s++){
                ch= seq1[s];
                if (ch == 'A'){
                    ctx.strokeStyle = 'green';
                } else if (ch=='C'){
                    ctx.strokeStyle = 'blue';
                } else if (ch=='G'){
                    ctx.strokeStyle = 'black';
                } else if (ch=='T'){
                    ctx.strokeStyle = 'red';
                } else {
                    ctx.strokeStyle = 'gray';
                }

                x=x+10;
                ctx.strokeText(ch, x, y);
            }

            y=y+20;

        //end for through used_reads:
        }

        // render aligned consensus sequence:
        if (partial_contig.aligned_sequence != null) {
            //qual row:
            ctx.strokeStyle = 'gray';
            x=0;
            y+=20;
            ctx.font = '5pt Courier New';
            x=block_start;

            for (s=0; s< partial_contig.aligned_qualities.length; s++){
                ch= partial_contig.aligned_qualities[s];
                x=x+10;
                if (partial_contig.aligned_qualities[s]!=-1){
                    ctx.strokeText(ch, x, y);
                }
            }

            x=0;
            y+=20;

            //sequence row:
            ctx.strokeStyle = 'black';
            ctx.font = '8pt Arial';
            ctx.strokeText('Consensus', x, y);
            ctx.strokeStyle = 'gray';
            ctx.font = '10pt Courier New';

            x=block_start;

            for (s=0; s< partial_contig.aligned_sequence.length; s++){
                ch= partial_contig.aligned_sequence[s];
                if (ch == 'A'){
                    ctx.strokeStyle = 'green';
                } else if (ch=='C'){
                    ctx.strokeStyle = 'blue';
                } else if (ch=='G'){
                    ctx.strokeStyle = 'black';
                } else if (ch=='T'){
                    ctx.strokeStyle = 'red';
                } else {
                    ctx.strokeStyle = 'gray';
                }
                x=x+10;
                ctx.strokeText(ch, x, y);
            }
            y+=20;

        }
        y+=20;

        //end loop through partial_cons
    }
    y+=20;
}

function downloadCanvas(link, canvasId, filename) {
    link.href = document.getElementById(canvasId).toDataURL();
    link.download = filename;
}

// draw in 0,0
function draw_trace_segment(ctx, pr, first_position, second_position){

    var trace_ymax=50;
    var yscale=40;

    <!--A trace-->
    ctx.strokeStyle = 'green';

    var x=0;
    var y=trace_ymax-pr.atrace[xpos]/yscale;
    ctx.moveTo(x,y);
    ctx.beginPath();
    for(var xpos = first_position; xpos <= second_position; xpos++){
        y=trace_ymax-pr.atrace[xpos]/yscale;
        ctx.lineTo(x,y);
        ctx.moveTo(x,y);
        x++;
    }
    ctx.stroke();
    ctx.closePath();

    <!--C trace-->
    ctx.strokeStyle = 'blue';

    var x=0;
    var y=trace_ymax-pr.ctrace[xpos]/yscale;
    ctx.moveTo(x,y);
    ctx.beginPath();
    for(var xpos = first_position; xpos <= second_position; xpos++){
        y=trace_ymax-pr.ctrace[xpos]/yscale;
        ctx.lineTo(x,y);
        ctx.moveTo(x,y);
        x++;
    }
    ctx.stroke();
    ctx.closePath();

    <!--G trace-->
    ctx.strokeStyle = 'black';

    var x=0;
    var y=trace_ymax-pr.gtrace[xpos]/yscale;
    ctx.moveTo(x,y);
    ctx.beginPath();
    for(var xpos = first_position; xpos <= second_position; xpos++){
        y=trace_ymax-pr.gtrace[xpos]/yscale;
        ctx.lineTo(x,y);
        ctx.moveTo(x,y);
        x++;
    }
    ctx.stroke();
    ctx.closePath();

    <!--T trace-->
    ctx.strokeStyle = 'red';

    var x=0;
    var y=trace_ymax-pr.ttrace[xpos]/yscale;
    ctx.moveTo(x,y);
    ctx.beginPath();
    for(var xpos = first_position; xpos <= second_position; xpos++){
        y=trace_ymax-pr.ttrace[xpos]/yscale;
        ctx.lineTo(x,y);
        ctx.moveTo(x,y);
        x++;
    }
    ctx.stroke();
    ctx.closePath();
}


