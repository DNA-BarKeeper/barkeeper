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
    }

});


function draw_chromatogram(chromatogram1){

    var change_base_primer_read_url='/primer_reads/'+chromatogram1.id+'/change_base';

    var ymax=250;

    var scale=4;

    var lineFunction = d3.svg.line()
        .x(function(d,i) { return i; })
        .y(function(d) { return ymax-d/scale; })
        .interpolate("linear");

    d3.select('#chromatogram')
        .append('svg')
        .attr('width', chromatogram1.atrace.length)
        .attr('height', 250);

    //draw clipped areas
    if (chromatogram1.trimmedReadStart){

        d3.select('svg').append('rect')
            .attr("x", 0)
            .attr("y", 0)
            .attr("width", chromatogram1.peak_indices[chromatogram1.trimmedReadStart-1]-5)
            .attr("height", ymax)
            .attr("fill", "#d3d3d3");

        d3.select('svg').append('rect')
            .attr("x", chromatogram1.peak_indices[chromatogram1.trimmedReadEnd-1]+5)
            .attr("y", 0)
            .attr("width", chromatogram1.atrace.length-chromatogram1.peak_indices[chromatogram1.trimmedReadEnd-1]+5)
            .attr("height", ymax)
            .attr("fill", "#d3d3d3");
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


    //draw base calls

    for(var i = 0; i < chromatogram1.peak_indices.length; i++){
        pos = chromatogram1.peak_indices[i];
        var ch = chromatogram1.sequence[i];

        var color='gray';
        var ta='middle';

        // position indicator
        var disp = i+1;

        if(disp % 10 == 0){

            d3.select('svg').append("text")
                .attr("x", pos)
                .attr("y", 10)
                .text(disp)
                .attr("font-family", "sans-serif")
                .attr("font-size", "7px")
                .attr("fill", color)
                .attr("text-anchor", ta);
            d3.select('svg').append("text")
                .attr("x", pos)
                .attr("y", 17)
                .text('.')
                .attr("font-family", "sans-serif")
                .attr("font-size", "7px")
                .attr("fill", color)
                .attr("text-anchor", ta);
        }

        //base calls
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

        d3.select('svg').append("text")
            .attr("x", pos)
            .attr("y", 30)
            .text(ch)
            .attr("font-family", "sans-serif")
            .attr("font-size", "10px")
            .attr("fill", color)
            .attr("text-anchor", ta)
            .attr("id", i)

            .on('mouseover', function(){
                d3.select(this)
                    .style('font-size','14px')
                    .style('font-weight', 'bold')
            })
            .on('mouseout', function(){
                d3.select(this)
                    .style('font-size','10px')
                    .style('font-weight', 'normal')
            })
            .on('dblclick', function(){
                var selected_base=d3.select(this);
                var current_char=selected_base.text();
                var pos = selected_base.attr("id");
                if (current_char=="A"){
                    selected_base.text("C");
                    selected_base.attr("fill", 'blue');
                    change_base(pos, "G", change_base_primer_read_url);
                } else if (current_char=="C"){
                    selected_base.text("G");
                    selected_base.attr("fill", 'black');
                    change_base(pos, "G", change_base_primer_read_url);
                } else if (current_char=="G"){
                    selected_base.text("T");
                    selected_base.attr("fill", 'red');
                    change_base(pos, "T", change_base_primer_read_url);
                } else if (current_char=="T"){
                    selected_base.text("_");
                    selected_base.attr("fill", 'grey');
                    change_base(pos, "_", change_base_primer_read_url);
                } else if (current_char=="_"){
                    selected_base.text("A");
                    selected_base.attr("fill", 'green');
                    change_base(pos, "A", change_base_primer_read_url);
                }
            })
            .on('contextmenu', function(){

                var selected_base=d3.select(this);
                var current_x=selected_base.attr("x");
                var current_y=selected_base.attr("y");

                current_x=parseInt(current_x)+5;

                d3.select('svg').append("text")
                    .attr("x", current_x)
                    .attr("y", current_y)
                    .text("A")
                    .attr("font-family", "sans-serif")
                    .attr("font-size", "10px")
                    .attr("fill", "grey")
                    .attr("text-anchor", "middle")
                    .on('mouseover', function(){
                        d3.select(this)
                            .style('font-size','14px')
                            .style('font-weight', 'bold')
                    })
                    .on('mouseout', function(){
                        d3.select(this)
                            .style('font-size','10px')
                            .style('font-weight', 'normal')
                    })
                    .on('dblclick', function(){
                        var selected_base=d3.select(this);
                        var current_char=selected_base.text();
                        if (current_char=="A"){
                            selected_base.text("C");
                            selected_base.attr("fill", 'blue');
                        } else if (current_char=="C"){
                            selected_base.text("G");
                            selected_base.attr("fill", 'black');
                        } else if (current_char=="G"){
                            selected_base.text("T");
                            selected_base.attr("fill", 'red');
                        } else if (current_char=="T"){
                            selected_base.text("-");
                            selected_base.attr("fill", 'grey');
                        } else if (current_char=="-"){
                            selected_base.text("A");
                            selected_base.attr("fill", 'green');
                        }
                    })
            });

        color='gray';

        //quality scores

        d3.select('svg').append("text")
            .attr("x", pos)
            .attr("y", 40)
            .text(chromatogram1.qualities[i])
            .attr("font-family", "sans-serif")
            .attr("font-size", "7px")
            .attr("fill", color)
            .attr("text-anchor", ta);
    }
}

function change_base(pos, base, change_base_primer_read_url) {
    console.log(pos, base, change_base_primer_read_url);
    $.ajax({
        data: {
            'position': pos,
            'base': base
        },
        type: 'POST',
        url: change_base_primer_read_url,
        success: function () {
        },
        error: function (response) {
            // we had an error
            alert('Could not change base at pos. '+pos+' to '+base+'. \n' +response);
        }
    });
    return 0;
}
