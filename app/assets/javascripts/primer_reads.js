jQuery(function() {
    $('#new_primer_read').fileupload(
        {
            dataType: "script",
            add: function(e, data) {
                data.context = $(tmpl("template-upload", data.files[0]));
                $('#new_primer_read').append(data.context);
                return data.submit();
            },
            progress: function(e, data) {
                var progress;
                if (data.context) {
                    progress = parseInt(data.loaded / data.total * 100, 10);
                    return data.context.find('.progress-bar.progress-bar-striped.active').css('width', progress + '%');
                }
            }
        }
    );
    $('#primer_reads').DataTable({
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#primer_reads').data('source'),
        "columnDefs": [
            { "orderable": false, "targets": 2 },
            { "orderable": false, "targets": 4 }
        ],
        "order": [ 3, 'desc' ]
    });
    $('#primer_read_contig_name').autocomplete( {
        source: $('#primer_read_contig_name').data('autocomplete-source')
    });

//    draw chromatogram
    var chromatogram1 = $('#chromatogram').data('url');

    if (chromatogram1){
        draw_chromatogram(chromatogram1);

        //clean up
        $('#loading').remove()
    }

});


function draw_chromatogram(chromatogram1){

    var ymax=250;

    //mk dynamic via slider (deactivated) or createJS -mouse-drag later:
    var scale=4;

    var lineFunction = d3.svg.line()
        .x(function(d,i) { return i; })
        .y(function(d) { return ymax-d/scale; })
        .interpolate("linear");

    d3.select('#chromatogram')
        .append('svg')
        .attr('width', chromatogram1.atrace.length)
        .attr('height', 250)

    //draw clipped areas
    if (chromatogram1.trimmedReadStart){

        d3.select('svg').append('rect')
            .attr("x", 0)
            .attr("y", 0)
            .attr("width", chromatogram1.peak_indices[chromatogram1.trimmedReadStart-1]-5)
            .attr("height", ymax)
            .attr("fill", "#d3d3d3")

        d3.select('svg').append('rect')
            .attr("x", chromatogram1.peak_indices[chromatogram1.trimmedReadEnd-1]+5)
            .attr("y", 0)
            .attr("width", chromatogram1.atrace.length-chromatogram1.peak_indices[chromatogram1.trimmedReadEnd-1]+5)
            .attr("height", ymax)
            .attr("fill", "#d3d3d3")
    }

    //draw traces

    d3.select('svg').append("path")
        .attr("d", lineFunction(chromatogram1.atrace))
        .attr("stroke", "green")
        .attr("stroke-width", 1)
        .attr("fill", "none");
    d3.select('svg').append("path")
        .attr("d", lineFunction(chromatogram1.ctrace))
        .attr("stroke", "blue")
        .attr("stroke-width", 1)
        .attr("fill", "none");
    d3.select('svg').append("path")
        .attr("d", lineFunction(chromatogram1.gtrace))
        .attr("stroke", "black")
        .attr("stroke-width", 1)
        .attr("fill", "none");
    d3.select('svg').append("path")
        .attr("d", lineFunction(chromatogram1.ttrace))
        .attr("stroke", "red")
        .attr("stroke-width", 1)
        .attr("fill", "none");

//    draw base calls

    for(var i = 0; i < chromatogram1.peak_indices.length; i++){
        pos = chromatogram1.peak_indices[i];
        var ch = chromatogram1.sequence[i];

        var color='gray';
        var ta='middle';


        var disp = i+1;
        if(disp % 10 == 0){

            //ctx.strokeText(disp, pos, 20);
            d3.select('svg').append("text")
                .attr("x", pos)
                .attr("y", 20)
                .text(disp)
                .attr("font-family", "sans-serif")
                .attr("font-size", "7px")
                .attr("fill", color)
                .attr("text-anchor", ta);

            //ctx.strokeText('.', pos, 27);
            d3.select('svg').append("text")
                .attr("x", pos)
                .attr("y", 27)
                .text('.')
                .attr("font-family", "sans-serif")
                .attr("font-size", "7px")
                .attr("fill", color)
                .attr("text-anchor", ta);
        }



        if (ch == 'A') {
            color = 'green';
        } else if (ch == 'C') {
            color = 'blue';
        } else if (ch == 'G') {
            color = 'black';
        } else if (ch == 'T') {
            color = 'red';
        }

        //ctx.font = '10pt Courier New';
        //ctx.strokeText(ch, pos, 40);
        //ctx.font = '5pt Courier New';
        //ctx.strokeStyle = 'gray';
        //ctx.strokeText(chromatogram1.qualities[i], pos, 60);

        d3.select('svg').append("text")
            .attr("x", pos)
            .attr("y", 40)
            .text(ch)
            .attr("font-family", "sans-serif")
            .attr("font-size", "9px")
            .attr("fill", color)
            .attr("text-anchor", ta);
    }

//
//    ctx.textAlign='center';
//
//    ctx.fillStyle = '#d3d3d3';
//
//
//
////  base calls
//    var pos=0;
//
//    for(var i = 0; i < chromatogram1.peak_indices.length; i++){
//        pos = chromatogram1.peak_indices[i];
//        var ch = chromatogram1.sequence[i];
//
//        ctx.strokeStyle = 'gray';
//        ctx.font = '7pt Courier New';
//
//        var disp = i+1;
//        if(disp % 10 == 0){
//            ctx.strokeText(disp, pos, 20);
//            ctx.strokeText('.', pos, 27);
//        }
//
//        if (ch == 'A') {
//            ctx.strokeStyle = 'green';
//        } else if (ch == 'C') {
//            ctx.strokeStyle = 'blue';
//        } else if (ch == 'G') {
//            ctx.strokeStyle = 'black';
//        } else if (ch == 'T') {
//            ctx.strokeStyle = 'red';
//        } else {
//            ctx.strokeStyle = 'gray';
//        }
//
//        ctx.font = '10pt Courier New';
//        ctx.strokeText(ch, pos, 40);
//        ctx.font = '5pt Courier New';
//        ctx.strokeStyle = 'gray';
//        ctx.strokeText(chromatogram1.qualities[i], pos, 60);
//    }
}