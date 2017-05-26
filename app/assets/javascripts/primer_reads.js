jQuery(function() {

    function scroll_to(pos) {
        var primer_read_divs = document.getElementsByClassName('chromatogram');

        for (var e = 0; e < primer_read_divs.length; e++) {
            var div = primer_read_divs[e];
            var div_id = '#' + div.id;
            var chromatogram1 = $(div_id).data('url');
            var scroll_to = chromatogram1.peak_indices[pos - 1];


            $('.alignment').animate({
                scrollLeft: scroll_to - 7
            }, 0);
        }
    }

    $('#go-to-button').click( function () {
        var pos=$('#go-to-pos').val();

        scroll_to(pos);
    });

    $('#scroll-left-button').click( function () {

        $('.alignment').animate({
            scrollLeft: 0
        }, 0);
    });

    $('#scroll-right-button').click( function () {

        //get div chromatogram & its current width
        var el  = document.getElementById("chromatogram_svg"); // or other selector like querySelector()
        var rect = el.getBoundingClientRect(); // get the bounding rectangle

        $('.alignment').animate({
            scrollLeft: rect.width
        }, 0);
    });
    
    $('#pause-button').click( function () {
        $('.alignment').stop();
    });

    $('#scroll-right-slowly-button').click( function () {

        //get div chromatogram & its current width
        var el  = document.getElementById("chromatogram_svg"); // or other selector like querySelector()
        var rect = el.getBoundingClientRect(); // get the bounding rectangle

        var curr_scroll_pos=$('.alignment').scrollLeft();
        
        var duration = (rect.width - curr_scroll_pos )*3;

        $('.alignment').animate({
            scrollLeft: rect.width
        }, duration, "swing" );
    });


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
    $('#primer_reads-duplicates').DataTable({
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#primer_reads-duplicates').data('source'),
        "columnDefs": [
            { "orderable": false, "targets": 2 },
            { "orderable": false, "targets": 4 }
        ],
        "order": [ 0, 'asc' ]
    });
    $('#reads_without_contigs').DataTable({
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#reads_without_contigs').data('source'),
        "columnDefs": [
            { "orderable": false, "targets": 2 },
            { "orderable": false, "targets": 4 }
        ],
        "order": [ 3, 'desc' ]
    });
    $('#primer_read_contig_name').autocomplete( {
        source: $('#primer_read_contig_name').data('autocomplete-source')
    });

    draw_chromatogram();

    var pos=$('#chromatogram_container').data("pos");

    if (pos > 0) {

        scroll_to(pos);

    }

});


function draw_chromatogram(){

    // über alle divs einer classe iterieren und die dort jeweiligen read data zum Zeichnen nutzen -> should be only 1 here.
    var primer_read_divs = document.getElementsByClassName('chromatogram');

    for (var e = 0; e < primer_read_divs.length; e++) {

        var div = primer_read_divs[e];

        var div_id='#'+div.id;

        var chromatogram1 = $(div_id).data('url');

        var ymax = 250;

        var scale = 4;

        var lineFunction = d3.svg.line()
            .x(function (d, i) {
                return i;
            })
            .y(function (d) {
                return ymax - d / scale;
            })
            .interpolate("linear");

        var svg = d3.select(div_id)
            .append('svg')
            .attr('width', chromatogram1.atrace.length)
            .attr('height', 250)
            .attr('id', 'chromatogram_svg');


        //adjust clipped areas:

        var drag_left = d3.behavior.drag()
            .on('dragstart', function() { left_clip_area.style('fill', '#eeebb5'); })
            .on('drag', function() {
                left_clip_area.attr('width', d3.event.x);
            })
            .on('dragend', function() {
                left_clip_area.style('fill', "#d3d3d3");

                var drawn_position=left_clip_area.attr('width');

                // find  peak closest to new x -> in chromatogram1.peak_indices
                for(var g=0; g < chromatogram1.peak_indices.length; g++) {
                    // console.log(drawn_position);
                    // console.log(g);
                    // console.log(chromatogram1.peak_indices[g]);
                    // console.log("\n");
                    // console.log(chromatogram1.peak_indices[g]-drawn_position);
                    if (chromatogram1.peak_indices[g]-drawn_position > 0) {
                        break;
                    }
                }

                // alert(g);

                change_left_clip(g+1, '/primer_reads/' + chromatogram1.id + '/change_left_clip');
            });

        var drag_right = d3.behavior.drag()
            .on('dragstart', function() { right_clip_area.style('fill', '#eeebb5'); })
            .on('drag', function() {
                right_clip_area.attr('x', d3.event.x).attr('width', chromatogram1.atrace.length - d3.event.x);
            })
            .on('dragend', function() {
                right_clip_area.style('fill', "#d3d3d3");

                var drawn_position=right_clip_area.attr('x');

                // find  peak closest to new x -> in chromatogram1.peak_indices
                for(var g=chromatogram1.peak_indices.length; g > 0 ; g--) {
                    // console.log(drawn_position);
                    console.log(g);
                    console.log(chromatogram1.peak_indices[g]);
                    console.log("\n");
                    console.log(chromatogram1.peak_indices[g]-drawn_position);
                    if (chromatogram1.peak_indices[g]-drawn_position < 0) {
                        break;
                    }
                }

                // alert(g);

                change_right_clip(g+1, '/primer_reads/' + chromatogram1.id + '/change_right_clip');

            });

        //draw clipped areas

        if (chromatogram1.trimmedReadStart) {

            var left_clip_area=svg.append('rect')
                .attr("x", 0)
                .attr("y", 0)
                .attr("width", chromatogram1.peak_indices[chromatogram1.trimmedReadStart - 1] - 5)
                .attr("height", ymax)
                .attr("fill", "#d3d3d3")
                .call(drag_left).on({
                    "mouseover": function(d) {
                        d3.select(this).style("cursor", "col-resize")
                    },
                    "mouseout": function(d) {
                        d3.select(this).style("cursor", "default");
                    }
                });

            var right_clip_area=svg.append('rect')
                .attr("x", chromatogram1.peak_indices[chromatogram1.trimmedReadEnd - 1] + 5)
                .attr("y", 0)
                .attr("width", chromatogram1.atrace.length - chromatogram1.peak_indices[chromatogram1.trimmedReadEnd - 1] + 5)
                .attr("height", ymax)
                .attr("fill", "#d3d3d3")
                .call(drag_right).on({
                    "mouseover": function(d) {
                        d3.select(this).style("cursor", "col-resize")
                    },
                    "mouseout": function(d) {
                        d3.select(this).style("cursor", "default")
                    }
                });
        }

        var highlighted_base=$('#chromatogram_container').data("pos");

        var highlight_pos = chromatogram1.peak_indices[highlighted_base - 1];

       var highlight = svg.append('rect')
           .attr("x", highlight_pos-7)
           .attr("y", 15)
           .attr("width", 12)
           .attr("height", 20)
           .attr("fill", "#fcff00");


        //draw traces

        svg.append("path")
            .attr("d", lineFunction(chromatogram1.atrace))
            .attr("stroke", "green")
            .attr("stroke-width", 1)
            .attr("fill", "none");
        svg.append("path")
            .attr("d", lineFunction(chromatogram1.ctrace))
            .attr("stroke", "blue")
            .attr("stroke-width", 1)
            .attr("fill", "none");
        svg.append("path")
            .attr("d", lineFunction(chromatogram1.gtrace))
            .attr("stroke", "black")
            .attr("stroke-width", 1)
            .attr("fill", "none");
        svg.append("path")
            .attr("d", lineFunction(chromatogram1.ttrace))
            .attr("stroke", "red")
            .attr("stroke-width", 1)
            .attr("fill", "none");


        //draw base calls

        for (var i = 0; i < chromatogram1.peak_indices.length; i++) {
            var pos = chromatogram1.peak_indices[i];
            var ch = chromatogram1.sequence[i];

            var color = 'gray';
            var ta = 'middle';

            // position indicator
            var disp = i + 1;

            if (disp % 10 == 0) {

                svg.append("text")
                    .attr("x", pos)
                    .attr("y", 10)
                    .text(disp)
                    .attr("font-family", "sans-serif")
                    .attr("font-size", "7px")
                    .attr("fill", color)
                    .attr("text-anchor", ta);
                svg.append("text")
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

            svg.append("text")
                .attr("x", pos)
                .attr("y", 30)
                .text(ch)
                .attr("font-family", "sans-serif")
                .attr("font-size", "10px")
                .attr("fill", color)
                .attr("text-anchor", ta)
                .attr("id", i)

                .on('mouseover', function () {
                    d3.select(this)
                        .style('font-size', '14px')
                        .style('font-weight', 'bold')
                })
                .on('mouseout', function () {
                    d3.select(this)
                        .style('font-size', '10px')
                        .style('font-weight', 'normal')
                })
                .on('click', function () {
                    var p = this.parentNode;


                    var selected_base = d3.select(this);
                    var p_el = d3.select(p);


                    var current_x = selected_base.attr("x");
                    var current_y = selected_base.attr("y");
                    var current_char = selected_base.text();
                    var base_index = selected_base.attr("id");

                    var frm = p_el.append("foreignObject");

                    var inp = frm
                        .attr({
                            'x': current_x - 5,
                            'y': 12,
                            'width': 20,
                            'height': 20
                        })
                        .append("xhtml:form")
                        .append('xhtml:input')
                        .attr("value", current_char)
                        .on("keypress", function () {

                            if (d3.event.keyCode === 13) {

                                d3.event.preventDefault(); // cancel default behavior

                                var newBase = inp.node().value;

                                if (newBase == " " || newBase == "" || newBase == "_") {
                                    newBase = "-";
                                }

                                //compute read id via div-id obtained from selecting parent of parent....
                                change_base(base_index, newBase, '/primer_reads/' + chromatogram1.id + '/change_base');

                                selected_base.text(newBase);

                                if (newBase == "A") {
                                    selected_base.attr("fill", 'green');
                                } else if (newBase == "C") {
                                    selected_base.attr("fill", 'blue');
                                } else if (newBase == "G") {
                                    selected_base.attr("fill", 'black');
                                } else if (newBase == "T") {
                                    selected_base.attr("fill", 'red');
                                } else {
                                    selected_base.attr("fill", 'grey');
                                }

                                frm.remove();
                            }
                        });

                });

            color = 'gray';

            //quality scores
            var q = chromatogram1.qualities[i];
            //ignore manually entered bases with fake qualities "-10"
            if (q > -10) {
                svg.append("text")
                    .attr("x", pos)
                    .attr("y", 40)
                    .text(q)
                    .attr("font-family", "sans-serif")
                    .attr("font-size", "7px")
                    .attr("fill", color)
                    .attr("text-anchor", ta);
            }

        }
    }

}

function change_base(base_index, base, change_base_primer_read_url) {
    // console.log(base_index, base, change_base_primer_read_url);
    $.ajax({
        data: {
            'position': base_index,
            'base': base
        },
        type: 'POST',
        url: change_base_primer_read_url,
        success: function () {
            var visible_index=parseInt(base_index);
            visible_index+=1;
            tempAlert("Changed base at position "+visible_index+" to "+base+", started re-assembly of contig and re-computing consensus", 3000);
        },
        error: function (response) {
            alert('Not authorized? Could not change base at index '+base_index+' to '+base);
        }
    });

    //todo ?:
    return 0;
}

function change_left_clip(base_index, change_left_clip_read_url) {

    $.ajax({
        data: {
            'position': base_index
        },
        type: 'POST',
        url: change_left_clip_read_url,
        success: function () {
            document.getElementById("left_clip").value = base_index;

            tempAlert("Set left clip position to "+base_index+", started re-assembly of contig and re-computing consensus", 3000);
        },
        error: function () {
            alert('Not authorized? Could not set left clip at index '+base_index);
        }
    });

    return 0;
}

function change_right_clip(base_index, change_right_clip_read_url) {

    $.ajax({
        data: {
            'position': base_index
        },
        type: 'POST',
        url: change_right_clip_read_url,
        success: function () {

            document.getElementById("right_clip").value = base_index;

            tempAlert("Set right clip position to "+base_index+ ", started re-assembly of contig and re-computing consensus", 3000);
        },
        error: function () {
            alert('Not authorized? Could not set right clip at index '+base_index);
        }
    });

    return 0;
}


function tempAlert(msg,duration)
{
    var el = document.createElement("div");
    el.setAttribute("style","position:absolute;top:50%;left:50%;background-color:#fcffcc;");
    el.innerHTML = msg;
    setTimeout(function(){
        el.parentNode.removeChild(el);
    },duration);
    document.body.appendChild(el);
}