jQuery(function() {
    if (document.getElementById("progress_tree") != null) {
        $("#progress_diagram_marker_select").on("change", () => $.ajax({
            type: "GET",
            contentType: "application/json; charset=utf-8",
            url: 'progress_tree',
            dataType: 'json',
            data: {
                marker_id: $('#progress_diagram_marker_select option:selected').val()
            },
            success: function (data) {
                deleteVisualization('#progress_tree');
                drawProgressTree(data[0]);
            },
            error: function (_result) {
                console.error("Error getting data.");
            }
        }));
    }

    // Download button and tree navigation are disabled on page load
    var message = 'Please select a marker first';
    disableButton($('#download_csv'), message);
    disableButton($('#reset_zoom'), message);

    $('#progress_diagram_marker_select').change(function() {
        // Add selected marker ID to download button link attribute
        var button = $('#download_csv');
        var marker_id = $('#progress_diagram_marker_select option:selected').val();
        button.attr('href', '/progress_overview/export_progress_csv?marker_id=' + marker_id)

        // Enable download button
        changeDownloadButtonStatus();
    });
});

function changeDownloadButtonStatus() {
    var button = $('#download_csv');
    var no_marker_selected = !$('#progress_diagram_marker_select option:selected').length;

    if (no_marker_selected) {
        disableButton(button);
    }
    else {
        enableButton(button);
    }
}

// Main function to draw and set up the visualization, once we have the data.
function drawProgressTree(data) {
    var parentDiv = document.getElementById("progress_tree");

    var width = parentDiv.clientWidth, // subtract padding and border width
        height = 710,
        scale = 1;

    var root = d3.hierarchy(data)
        .sort((a, b) => d3.ascending(a.data.scientific_name, b.data.scientific_name));

    var maxChildren = 0;
    var leaveCnt = 0;
    root.descendants().forEach(function(d) {
        if (!d.children){
            maxChildren = Math.max(maxChildren, d.data.size);
            leaveCnt++;
        }
    })

    var radius = Math.max(width/2, leaveCnt * 30 / (2 * Math.PI)); // Calculate tree radius from number of leave nodes with a minimum distance of 30

    var treeLayout = d3.cluster()
        .size([2 * Math.PI, radius - 150]);

    treeLayout(root);

    var svg = d3.select('#progress_tree')
        .append("svg")
        .attr('id', 'progress_svg')
        .attr('width', "100%")
        .attr('height', height)
        .attr("preserveAspectRatio", "xMinYMin slice")
        .attr("viewBox", "0 0 " + width + " " + height)
        .classed("svg-content", true);

    var mainGroup = svg.append('g')
        .attr('transform', 'translate(' + (width / 2) + ',' + radius + ')');

    // Enable zoom & pan
    var zoom = d3.zoom()
        .on("zoom", function() {
            mainGroup.attr("transform", d3.event.transform)
        });

    svg.call(zoom);

    // Trigger initial zoom with an initial transform
    zoom.transform(svg, d3.zoomIdentity.translate($("#progress_svg").width() / 2, radius).scale(scale));

    // Button to reset zoom and position
    d3.select("#reset_zoom")
        .on("click", function() {
            var current_width = $("#progress_svg").width();
            zoom.transform(svg, d3.zoomIdentity.translate(current_width / 2, radius).scale(scale));
        });
    enableButton($('#reset_zoom'));

    // draw links
    mainGroup.append('g')
        .attr("fill", "none")
        .attr("stroke", "#555")
        .attr("stroke-opacity", 0.4)
        .attr("stroke-width", 1.5)
        .selectAll('path.link')
        .data(root.links())
        .enter()
        .append("line")
        .attr("class", "link")
        .attr("x1", function(d) { return radialPoint(d.source.x,d.source.y)[0]; })
        .attr("y1", function(d) { return radialPoint(d.source.x,d.source.y)[1]; })
        .attr("x2", function(d) { return radialPoint(d.target.x,d.target.y)[0]; })
        .attr("y2", function(d) { return radialPoint(d.target.x,d.target.y)[1]; });

    var tooltip = d3.select('#progress_tree')
        .append("div")
        .style("opacity", 0)
        .attr("class", "tooltip")
        .style("border", "1px solid #555")
        .style("border-radius", "5px")
        .style("padding", "5px")

    // Build color scale
    var step = d3.scaleLinear()
        .domain([1, 8])
        .range([0, 100]);

    // Scale from red to green in 8 steps
    var nodeColor = d3.scaleLinear()
        .domain([0, step(2), step(3), step(4), step(5), step(6), step(7), 100])
        .range(['#d73027', '#f46d43', '#fdae61', '#fee08b', '#d9ef8b', '#a6d96a', '#66bd63', '#1a9850'])
        .interpolate(d3.interpolateHcl);

    // Draw nodes
    nodes = mainGroup.append('g')
        .selectAll('circle.node')
        .data(root.descendants());

    nodeEnter = nodes.enter()
        .append("g")
        .attr("font-family", "sans-serif")
        .attr("font-size", 14)
        .attr("stroke-linejoin", "round")
        .on("mouseover",  function(d) {
            tooltip.transition()
                .style("fill-opacity", .2)
                .style("background-color", 'lightgrey')
                .style("border", "3px solid " + nodeColor((d.data.finished_size / d.data.size) * 100))
                .duration(300)
                .style("opacity", 1);

            d3.select(this)
                .style("stroke-width", '2px')
                .style("font-weight", 'bold')
                .raise();
        })
        .on("mousemove", function(d) {
            var finished_percent = d.data.size === 0 ? '' : " (" + ((d.data.finished_size / d.data.size) * 100).toFixed(2) + "%)";
            tooltip
                .html(d.data.scientific_name + ":<br>" + d.data.size + " species (incl. subspecies)<br>" + d.data.finished_size
                    + " finished" + finished_percent)
                .style("left", (d3.event.pageX - parentDiv.offsetLeft + 10) + "px")
                .style("top", (d3.event.pageY - parentDiv.offsetTop + 20) + "px");
        })
        .on("mouseout", function mouseout() {
            tooltip.transition()
                .duration(300)
                .style("opacity", 1e-6);

            d3.select(this)
                .style("stroke-width", '1px')
                .style("font-weight", 'normal');
        });

    var nodeRadiusMin = 2;
    var nodeRadiusMax = 30;
    var nodeSizeScale = d3.scaleLinear()
        .domain([0, maxChildren])
        .range([nodeRadiusMin, nodeRadiusMax]);

    nodeEnter.append('circle')
      .attr('r', d => d.children ? nodeRadiusMin : nodeSizeScale(d.data.size))
      .style("stroke", "#555")
        .attr("fill", function(d) { return nodeColor((d.data.finished_size / d.data.size) * 100) })
      .attr("transform", d => `
         rotate(${d.x * 180 / Math.PI - 90})
         translate(${d.y},0)
      `);

    // Draw labels
    nodeEnter
        .append('text')
        .attr("transform", d => `
          rotate(${d.x * 180 / Math.PI - 90}) 
          translate(${d.y},0) 
          rotate(${d.x >= Math.PI ? 180 : 0})
		`)
        .attr("dy", "0.31em")
        .attr("x", function(d) {
            r = d.children ? nodeRadiusMin : nodeSizeScale(d.data.size);
            return d.x < Math.PI === !d.children ? (r + 6) : (0 - r - 6);
        })
        .attr("text-anchor", d => d.x < Math.PI === !d.children ? "start" : "end")
        .text(d => d.data.scientific_name);

    // Add a legend for the heat map color values
    var legendWidth = 20;
    var legendHeight = 250;

    // Append a defs (for definition) element to SVG
    var defs = svg.append("defs");

    // Append a linearGradient element to the defs and give it a unique id
    var linearGradient = defs.append("linearGradient")
        .attr("id", "progress-gradient");

    //Vertical gradient
    linearGradient
        .attr("x1", "0%")
        .attr("y1", "0%")
        .attr("x2", "0%")
        .attr("y2", "100%");

    //Extra scale since the color scale is interpolated
    var progressScale = d3.scaleLinear()
        .domain([0, 100])
        .range([0, width])

    //Calculate the variables for the temp gradient
    var numStops = 10;
    progressRange = progressScale.domain();
    progressRange[2] = progressRange[1] - progressRange[0];
    countPoint = [];
    for(var i = 0; i < numStops; i++) {
        countPoint.push(i * progressRange[2]/(numStops-1) + progressRange[0]);
    }

    //Append multiple color stops by using D3's data/enter step
    linearGradient.selectAll("stop")
        .data(d3.range(numStops))
        .enter().append("stop")
        .attr("offset", function(d,i) {
            return progressScale(countPoint[i])/width;
        })
        .attr("stop-color", function(d,i) {
            return nodeColor(countPoint[i]);
        });

    //Color Legend container
    var legendsvg = svg.append("g")
        .attr("class", "legendWrapper")
        .attr("transform", "translate(" + 50 + "," + 20 + ")");

    //Draw the Rectangle
    legendsvg.append("rect")
        .attr("class", "legendRect")
        .attr("x", -legendWidth/2)
        .attr("y", 0)
        .attr("width", legendWidth)
        .attr("height", legendHeight)
        .style("fill", "url(#progress-gradient)");

    //Append title
    legendsvg.append("text")
        .attr("class", "legendTitle")
        .attr("transform", "rotate(-90)")
        .attr("y", -legendWidth*2)
        .attr("x",0 - (legendHeight / 2))
        .attr("dy", "1em")
        .style("text-anchor", "middle")
        .text("Subtaxa with finished barcodes");

    //Set scale for x-axis
    var xScale = d3.scaleLinear()
        .range([0, legendHeight])
        .domain([0, 100]);

    //Define x-axis
    var xAxis = d3.axisRight(xScale)
        .ticks(5)
        .tickFormat(function(d) { return d + "%"; });

    //Set up X axis
    legendsvg.append("g")
        .attr("class", "axis")
        .attr("transform", "translate(" + legendWidth/2 + ",0)")
        .call(xAxis);

    function radialPoint(x, y) {
        return [(y = +y) * Math.cos(x -= Math.PI / 2), y * Math.sin(x)];
    }
}
