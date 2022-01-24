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
    $('.go-to-button_primer_read').click( function () {
        var read_id = $(this).data('readId');
        var input_id = "#go-to-pos_" + $(this).data('readId');
        var pos = $(input_id).val();

        if (pos > 0) {
            scroll_with_highlight(pos, read_id);
        }
    });

    // Support using keyboard to confirm 'go to position' input
    $('.go-to-pos').on('keypress',function(e) {
        if( e.keyCode === 13 ) {
            var read_id = $(this)[0].id.split('_')[1];
            var pos = $(this).val();

            if (pos > 0) {
                scroll_with_highlight(pos, read_id);
            }
        }
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

    var prev_drawn_position = 0;
    var prev_width = 0;
    //adjust clipped areas:
    var drag_left = d3.drag()
        .on('start', function() {
            left_clip_area.style('fill', '#eeebb5');
            prev_drawn_position = left_clip_area.attr('width');
        })
        .on('drag', function() {
            left_clip_area.attr('width', d3.event.x);
        })
        .on('end', function() {
            left_clip_area.style('fill', "#d3d3d3");

            var drawn_position = left_clip_area.attr('width');

            // find  peak closest to new x -> in chromatogram1.peak_indices
            for(var g=0; g < chromatogram.peak_indices.length; g++) {
                if (chromatogram.peak_indices[g] - drawn_position > 0) {
                    break;
                }
            }

            if(prev_drawn_position !== drawn_position) { // Avoid triggering action when user just clicks in clipped area
                change_left_clip(g, prev_drawn_position, chromatogram.id, div_id);
            }
        });

    var drag_right = d3.drag()
        .on('start', function() {
            right_clip_area.style('fill', '#eeebb5');
            prev_drawn_position = right_clip_area.attr('x');
            prev_width = right_clip_area.attr('width');
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

            if(prev_drawn_position !== drawn_position) { // Avoid triggering action when user just clicks in clipped area
                change_right_clip(g, prev_width, prev_drawn_position, chromatogram.id, div_id);
            }
        });

    //draw clipped areas

    if (chromatogram.trimmedReadStart) {

        var left_clip_area = svg.append('rect')
            .attr("x", 0)
            .attr("y", 0)
            .attr("width", chromatogram.peak_indices[chromatogram.trimmedReadStart - 1] - 5)
            .attr("height", ymax)
            .attr("fill", "#d3d3d3")
            .attr('class', 'left_clip_area')
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
            .attr('class', 'right_clip_area')
            .call(drag_right)
            .on('mouseover', function(d) {
                d3.select(this).style("cursor", "col-resize")
            })
            .on('mouseout', function(d) {
                d3.select(this).style("cursor", "default");
            });
    }

    var highlighted_base = $('#' + div_id).data("pos");

    if (highlighted_base > 0) {
        var highlight_pos = chromatogram.peak_indices[highlighted_base - 1];

        svg.append('rect')
            .attr("x", highlight_pos - 7)
            .attr("y", 15)
            .attr("width", 12)
            .attr("height", 250)
            .attr("fill", 'orange')
            .attr('opacity', '0.6')
            .attr("class", "highlight");
    }

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
        .attr("stroke", "orange")
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
                .attr("y", 12)
                .text(disp)
                .attr("font-family", "sans-serif")
                .attr("font-size", "10px")
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

        if (chromatogram.peak_indices[i-1]) {
            var left = (chromatogram.peak_indices[i - 1] + chromatogram.peak_indices[i]) / 2;
        }
        else {
            var left = 0;
        }

        if (chromatogram.peak_indices[i+1]) {
            var right = (chromatogram.peak_indices[i+1] + chromatogram.peak_indices[i]) / 2;
        }
        else {
            var right = chromatogram.peak_indices[i] * 2;
        }

        var width = right - left;

        svg.append('rect')
            .attr("x", left)
            .attr("y", 19)
            .attr("width", width)
            .attr("height", 15)
            .attr("id", "background_" + i)
            .attr("fill", color);

        svg.append("text")
            .attr("x", pos)
            .attr("y", 30)
            .text(ch)
            .attr("font-family", "sans-serif")
            .attr("font-size", "10px")
            .attr("font-weight", '600')
            .attr("fill", 'black')
            .attr("text-anchor", ta)
            .attr("id", "base_" + i)
            .attr("index", i)
            .on('mouseover', function () {
                d3.select(this)
                    .style('font-size', '14px')
                    .attr("font-weight", '800')
            })
            .on('mouseout', function () {
                d3.select(this)
                    .style('font-size', '10px')
                    .attr("font-weight", '600')
            })
            .on('click', function () {

                var selected_base = d3.select(this);
                var p_el = d3.select(this.parentNode);

                var current_x = selected_base.attr("x");
                var current_y = selected_base.attr("y");
                var current_char = selected_base.text();
                var base_index = selected_base.attr("index");

                var frm = p_el.append('foreignObject');

                var inp = frm
                    .attr('x', current_x - 5)
                    .attr('y', 12)
                    .attr('width', 20)
                    .attr('height', 20)
                    .attr('id', 'base_change')
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

                            var base_background = d3.select('#background_' + base_index);

                            if (newBase == "A") {
                                base_background.attr("fill", '#5AE45D');
                            } else if (newBase == "C") {
                                base_background.attr("fill", '#5A5AE6');
                            } else if (newBase == "G") {
                                base_background.attr("fill", '#E2E65A');
                            } else if (newBase == "T") {
                                base_background.attr("fill", '#E65A5A');
                            } else {
                                base_background.attr("fill", 'grey');
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
    var visible_index = parseInt(base_index) + 1;

    $.ajax({
        data: {
            'position': base_index,
            'base': base
        },
        type: 'POST',
        url: change_base_primer_read_url,
        success: function () {
            tempAlert("Changed base at position " + visible_index + " to " + base + "", 3000, div_id);
        },
        error: function (response) {
            alert('Not authorized? Could not change base at position ' + visible_index + ' to ' + base);
        }
    });

    //todo ?:
    return 0;
}

function change_left_clip(base_index, prev_width, read_id, div_id) {
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
            alert('Not authorized? Could not set left clip at position ' + base_index);
            d3.select('.left_clip_area').attr('width', prev_width);
        }
    });

    return 0;
}

function change_right_clip(base_index, prev_width, prev_x, read_id, div_id) {
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
            alert('Not authorized? Could not set right clip at position ' + base_index);
            d3.select('.right_clip_area').attr('width', prev_width);
            d3.select('.right_clip_area').attr('x', prev_x);
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
        .attr("height", 250)
        .attr("fill", 'orange')
        .attr('opacity', '0.6')
        .attr("class", "highlight")
        .moveToBack();

    svg.selectAll("rect.left_clip_area").moveToBack();
    svg.selectAll("rect.right_clip_area").moveToBack();
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