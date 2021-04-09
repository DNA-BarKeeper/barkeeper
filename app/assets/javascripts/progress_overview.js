jQuery(function() {
    if (document.getElementById("progress_tree") != null) {
        $.ajax({
            type: "GET",
            contentType: "application/json; charset=utf-8",
            url: 'progress_tree',
            dataType: 'json',
            processData: false,
            success: function (data) {
                drawProgressTree(data[0]);
            },
            error: function (result) {
                console.error("Error getting data.");
            }
        });
    }
});

// Main function to draw and set up the visualization, once we have the data.
function drawProgressTree(data) {
    var parentDiv = document.getElementById("progress_tree");

    var width = parentDiv.clientWidth,
        height = 650,
        scale = 1,
        nodeRadius = 2,
        radius = width / 2 - 50,
        duration = 750;

    var treeLayout = d3.cluster().size([2 * Math.PI, radius - 100]);

    var root = treeLayout(d3.hierarchy(data)
        .sort((a, b) => d3.ascending(a.data.scientific_name, b.data.scientific_name)));

    var svg = d3.select('#progress_tree')
        .append("svg")
        .attr('id', 'progress_svg')
        .attr('width', "100%")
        .attr('height', height)
        .attr("preserveAspectRatio", "xMinYMin slice")
        .attr("viewBox", "0 0 " + width + " " + height)
        .classed("svg-content", true);

    var mainGroup = svg.append('g')
        .attr('transform', 'translate(' + width / 2 + ',' + height / 2 + ')');

    // Enable zoom & pan
    var zoom = d3.zoom()
        .on("zoom", function() {
            mainGroup.attr("transform", d3.event.transform)
        });

    svg.call(zoom);

    // Button to reset zoom and position
    d3.select("#reset_zoom")
        .attr('style', 'margin: 5px')
        .on("click", function() {
            centerNode(root);
        });

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
        .style("background-color", "lightgrey")
        .style("border-color", "red")
        .style("border", "solid")
        .style("border-width", "1px")
        .style("border-radius", "5px")
        .style("padding", "5px")

    // Draw nodes
    nodes = mainGroup.append('g')
        .selectAll('circle.node')
        .data(root.descendants());

    nodeEnter = nodes.enter()
        .append("g")
        .attr("font-family", "sans-serif")
        .attr("font-size", 14)
        .attr("stroke-linejoin", "round")
        .on("mouseover",  function mouseover() {
            tooltip.transition()
                .duration(300)
                .style("opacity", 1);

            d3.select(this)
                .style("stroke-width", '2px')
                .style("font-weight", 'bold')
                .raise();
        })
        .on("mousemove", function(d) {
            tooltip
                .html(d.data.scientific_name + ":<br>" + d.data.size + " terminal nodes")
                .style("left", (d3.event.pageX) + "px")
                .style("top", (d3.event.pageY + 28) + "px");
        })
        .on("mouseout", function mouseout() {
            tooltip.transition()
                .duration(300)
                .style("opacity", 1e-6);

            d3.select(this)
                .style("stroke-width", '1px')
                .style("font-weight", 'normal');
        });

    nodeEnter.append('circle')
      .attr('r', d => d.children ? nodeRadius : ((d.data.size / 5) + 1))
      .style("stroke", "#555")
      .attr("fill", d => d.children ? "#555" : "#999")
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
            r = d.children ? nodeRadius : ((d.data.size / 5) + 1);
            return d.x < Math.PI === !d.children ? (r + 6) : (0 - r - 6);
        })
        .attr("text-anchor", d => d.x < Math.PI === !d.children ? "start" : "end")
        .text(d => d.data.scientific_name);

    function radialPoint(x, y) {
        return [(y = +y) * Math.cos(x -= Math.PI / 2), y * Math.sin(x)];
    }

    function centerNode(source) {
        x = $("#progress_svg").width() / 2; // Use current width of SVG
        y = height / 2;

        d3.select('g').transition()
            .duration(duration)
            .attr("transform", "translate(" + x + "," + y + ")scale(" + scale + ")");
        zoom.transform(svg, d3.zoomIdentity.translate(x, y).scale(scale));
    }
}