jQuery(function() {
    $('.go-to-button_primer_read').click( function () {
        var read_id = $(this).data('readId');
        var input_id = "#go-to-pos_" + $(this).data('readId');
        var pos = $(input_id).val();

        scroll_with_highlight(pos, read_id);
    });

    $('.scroll-left-button').click( function () {
        var id = "#chromatogram_container_" + $(this).data('readId');

        $(id).animate({
            scrollLeft: 0
        }, 0);
    });

    $('.scroll-right-button').click( function () {
        var readID = $(this).data('readId');
        var id = "#chromatogram_container_" + readID;

        //get div chromatogram & its current width
        var el  = document.getElementById("chromatogram_svg_primer_read_" + readID); // or other selector like querySelector()
        var rect = el.getBoundingClientRect(); // get the bounding rectangle

        $(id).animate({
            scrollLeft: rect.width
        }, 0);
    });

    $('.pause-button').click( function () {
        var id = "#chromatogram_container_" + $(this).data('readId');
        $(id).stop();
    });

    $('.scroll-right-slowly-button').click( function () {
        var readID = $(this).data('readId');
        var id = "#chromatogram_container_" + readID;

        //get div chromatogram & its current width
        var el  = document.getElementById("chromatogram_svg_primer_read_" + readID); // or other selector like querySelector()
        var rect = el.getBoundingClientRect(); // get the bounding rectangle

        var curr_scroll_pos = $(id).scrollLeft();

        var duration = (rect.width - curr_scroll_pos )*3;

        $(id).animate({
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
            { "orderable": false, "targets": 4 }
        ],
        "order": [ 3, 'desc' ]
    });

    $('#primer_reads-duplicates').DataTable({
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#primer_reads-duplicates').data('source'),
        "columnDefs": [
            { "orderable": false, "targets": 4 }
        ],
        "order": [ 0, 'asc' ]
    });

    $('#reads_without_contigs').DataTable({
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#reads_without_contigs').data('source'),
        "columnDefs": [
            { "orderable": false, "targets": 4 }
        ],
        "order": [ 3, 'desc' ]
    });

    $('#primer_read_contig_name').autocomplete( {
        source: $('#primer_read_contig_name').data('autocomplete-source')
    });

    // Iterate over all divs of class chromatogram and use available data to draw
    var primer_read_divs = document.getElementsByClassName('chromatogram');
    for (var i = 0; i < primer_read_divs.length; i++) {
        var div_id = primer_read_divs[i].id;

        var chromatogram = $('#' + div_id).data('url');

        var pos = $(primer_read_divs[i]).data("pos");

        var read_id = $(primer_read_divs[i]).data("readId");

        draw_chromatogram(div_id, chromatogram);

        if (pos > 0) {
            scroll_with_highlight(pos, read_id);
        }
    }
});

function draw_chromatogram(div_id, chromatogram){
    var ymax = 250;

    var scale = 4;

    var lineFunction = d3.line()
        .x(function (d, i) { return i; })
        .y(function (d) { return ymax - d / scale; });

    var svg = d3.select('#' + div_id)
        .append('svg')
        .attr('width', chromatogram.atrace.length)
        .attr('height', ymax)
        .attr('id', 'chromatogram_svg_' + div_id);

    //adjust clipped areas:
    var drag_left = d3.drag()
        .on('start', function() {
            left_clip_area.style('fill', '#eeebb5');
        })
        .on('drag', function() {
            left_clip_area.attr('width', d3.event.x);
        })
        .on('end', function() {
            left_clip_area.style('fill', "#d3d3d3");

            var drawn_position=left_clip_area.attr('width');

            // find  peak closest to new x -> in chromatogram1.peak_indices
            for(var g=0; g < chromatogram.peak_indices.length; g++) {
                if (chromatogram.peak_indices[g]-drawn_position > 0) {
                    break;
                }
            }

            change_left_clip(g+1, chromatogram.id, div_id);
        });

    var drag_right = d3.drag()
        .on('start', function() {
            right_clip_area.style('fill', '#eeebb5');
        })
        .on('drag', function() {
            right_clip_area.attr('x', d3.event.x).attr('width', chromatogram.atrace.length - d3.event.x);
        })
        .on('end', function() {
            right_clip_area.style('fill', "#d3d3d3");

            var drawn_position = right_clip_area.attr('x');

            // Find  peak closest to new x -> in chromatogram1.peak_indices
            for(var g = chromatogram.peak_indices.length; g > 0 ; g--) {
                if (chromatogram.peak_indices[g]-drawn_position < 0) {
                    break;
                }
            }

            change_right_clip(g+1, chromatogram.id, div_id);

        });

    //draw clipped areas

    if (chromatogram.trimmedReadStart) {

        var left_clip_area = svg.append('rect')
            .attr("x", 0)
            .attr("y", 0)
            .attr("width", chromatogram.peak_indices[chromatogram.trimmedReadStart - 1] - 5)
            .attr("height", ymax)
            .attr("fill", "#d3d3d3")
            .call(drag_left)
                .on('mouseover', function(d) {
                    d3.select(this).style("cursor", "col-resize")
                })
            .on('mouseout', function(d) {
                    d3.select(this).style("cursor", "default");
            });

        var right_clip_area = svg.append('rect')
            .attr("x", chromatogram.peak_indices[chromatogram.trimmedReadEnd - 1] + 5)
            .attr("y", 0)
            .attr("width", chromatogram.atrace.length - chromatogram.peak_indices[chromatogram.trimmedReadEnd - 1] + 5)
            .attr("height", ymax)
            .attr("fill", "#d3d3d3")
            .call(drag_right)
            .on('mouseover', function(d) {
                d3.select(this).style("cursor", "col-resize")
            })
            .on('mouseout', function(d) {
                d3.select(this).style("cursor", "default");
            });
    }

    var highlighted_base = $('#' + div_id).data("pos");

    var highlight_pos = chromatogram.peak_indices[highlighted_base - 1];

    var highlight = svg.append('rect')
        .attr("x", highlight_pos - 7)
        .attr("y", 15)
        .attr("width", 12)
        .attr("height", 20)
        .attr("fill", "#fcff00")
        .attr("class", "highlight");


    //draw traces

    svg.append("path")
        .attr("d", lineFunction(chromatogram.atrace))
        .attr("stroke", "green")
        .attr("stroke-width", 1)
        .attr("fill", "none");
    svg.append("path")
        .attr("d", lineFunction(chromatogram.ctrace))
        .attr("stroke", "blue")
        .attr("stroke-width", 1)
        .attr("fill", "none");
    svg.append("path")
        .attr("d", lineFunction(chromatogram.gtrace))
        .attr("stroke", "black")
        .attr("stroke-width", 1)
        .attr("fill", "none");
    svg.append("path")
        .attr("d", lineFunction(chromatogram.ttrace))
        .attr("stroke", "red")
        .attr("stroke-width", 1)
        .attr("fill", "none");


    //draw base calls

    for (var i = 0; i < chromatogram.peak_indices.length; i++) {
        var pos = chromatogram.peak_indices[i];
        var ch = chromatogram.sequence[i];

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

                var selected_base = d3.select(this);
                var p_el = d3.select(this.parentNode);

                var current_x = selected_base.attr("x");
                var current_y = selected_base.attr("y");
                var current_char = selected_base.text();
                var base_index = selected_base.attr("id");

                var frm = p_el.append('foreignObject');

                var inp = frm
                    .attr('x', current_x - 5)
                    .attr('y', 12)
                    .attr('width', 20)
                    .attr('height', 20)
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

                            change_base(base_index, newBase, chromatogram.id, div_id);

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
        var q = chromatogram.qualities[i];
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

function change_base(base_index, base, read_id, div_id) {
    var change_base_primer_read_url = '/primer_reads/' + read_id + '/change_base';

    $.ajax({
        data: {
            'position': base_index,
            'base': base
        },
        type: 'POST',
        url: change_base_primer_read_url,
        success: function () {
            var visible_index = parseInt(base_index);
            visible_index += 1;
            tempAlert("Changed base at position " + visible_index + " to " + base + "", 3000, div_id);
        },
        error: function (response) {
            alert('Not authorized? Could not change base at index ' + base_index + ' to ' + base);
        }
    });

    //todo ?:
    return 0;
}

function change_left_clip(base_index, read_id, div_id) {
    var change_left_clip_read_url = '/primer_reads/' + read_id + '/change_left_clip';

    $.ajax({
        data: {
            'position': base_index
        },
        type: 'POST',
        url: change_left_clip_read_url,
        success: function () {
            document.getElementById("left_clip_" + read_id).value = base_index;

            tempAlert("Set left clip position to " + base_index + "", 3000, div_id);
        },
        error: function () {
            alert('Not authorized? Could not set left clip at index ' + base_index);
        }
    });

    return 0;
}

function change_right_clip(base_index, read_id, div_id) {
    var change_right_clip_read_url = '/primer_reads/' + read_id + '/change_right_clip';

    $.ajax({
        data: {
            'position': base_index
        },
        type: 'POST',
        url: change_right_clip_read_url,
        success: function () {

            document.getElementById("right_clip_" + read_id).value = base_index;

            tempAlert("Set right clip position to " + base_index + "", 3000, div_id);
        },
        error: function () {
            alert('Not authorized? Could not set right clip at index '+base_index);
        }
    });

    return 0;
}

function scroll_with_highlight(position, read_id) {
    var chromatogram_position = $('#primer_read_' + read_id).data('url').peak_indices[position - 1];

    // Scroll to position
    $("#chromatogram_container_" + read_id).animate({
        scrollLeft: chromatogram_position - 7
    }, 0);

    // Position of elements depends on order in which they were added, so highlight has to be moved to the back
    d3.selection.prototype.moveToBack = function() {
        return this.each(function() {
            var firstChild = this.parentNode.firstChild;
            if (firstChild) {
                this.parentNode.insertBefore(this, firstChild);
            }
        });
    };

    var svg = d3.select('#chromatogram_svg_primer_read_' + read_id);

    svg.selectAll("rect.highlight").remove(); // Remove previous highlight

    // Add new highlight and move it to the back
    svg.append('rect')
        .attr("x", chromatogram_position - 7)
        .attr("y", 15)
        .attr("width", 12)
        .attr("height", 20)
        .attr("fill", "#fcff00")
        .attr("class", "highlight")
        .moveToBack();
}

function tempAlert(msg, duration, div_id) {
    var parent = document.getElementById(div_id).parentNode.parentNode;
    var el = document.createElement("div");

    el.setAttribute("style","position:absolute;top:38%;left:50%;background-color:#fcffcc;");
    el.innerHTML = msg;
    setTimeout(function(){
        parent.removeChild(el);
        parent.removeAttribute("style");
    },duration);
    parent.setAttribute('style', 'position:relative;');
    parent.appendChild(el);
}