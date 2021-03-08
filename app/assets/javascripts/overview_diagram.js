jQuery(function() {
    if (document.getElementById("all_species") != null) {
        $.ajax({
            type: "GET",
            contentType: "application/json; charset=utf-8",
            url: 'all_species',
            dataType: 'json',
            processData: false,
            success: function (data) {
                createVisualization(data, 'all');
            },
            error: function (result) {
                console.error("Error getting data.");
            }
        });
    }

    $("#overview_diagram_marker_select").on("change", () => $.ajax({
        type: "GET",
        contentType: "application/json; charset=utf-8",
        url: "finished_species_marker",
        dataType: "json",
        data: {
            marker_id: $('#overview_diagram_marker_select option:selected').val()
        },
        success: function (data) {
            deleteVisualization('finished'); // delete old visualization
            createVisualization(data, 'finished');
        },
        error: function (result) {
            console.error("Error getting data.");
        }
    }));
});

// Dimensions of sunburst.
var width = 550;
var height = 500;
var radius = Math.min(width, height) / 2;

// Breadcrumb dimensions: width, height, spacing, width of tip/tail.
var b = {
    w: 125, h: 30, s: 4, t: 10
};

var color = d3.scaleOrdinal(d3.schemeSet2);

// Total size of all segments; we set this later, after loading the data.
var totalSizes = [];

var vis;

var diagram_id;

// Main function to draw and set up the visualization, once we have the data.
function createVisualization(json, id) {
    diagram_id = id;

    vis = d3.select("#chart_" + diagram_id)
        .append("svg")
        .attr("width", width)
        .attr("height", height)
        .append("g")
        .attr("id", "container_" + diagram_id)
        .attr("transform", "translate(" + width / 2 + "," + height / 2 + ")");

    // Set diagram title
    header_text = (id == 'all') ? 'species' : 'barcode sequences';
    d3.select("#diagram_title_" + diagram_id).append("text")
        .attr("text-anchor", "middle")
        .style("font-size", "18px")
        .text("Number of " + header_text + " per taxon");

    var partition = d3.partition()
        .size([2 * Math.PI, radius * radius]);

    var arc = d3.arc()
        .startAngle(function(d) { return d.x0; })
        .endAngle(function(d) { return d.x1; })
        .innerRadius(function(d) { return Math.sqrt(d.y0); })
        .outerRadius(function(d) { return Math.sqrt(d.y1); });

    // Basic setup of page elements.
    initializeBreadcrumbTrail();

    // Bounding circle underneath the sunburst, to make it easier to detect
    // when the mouse leaves the parent g.
    vis.append("svg:circle")
        .attr("r", radius)
        .attr("id", "circle_" + diagram_id)
        .style("opacity", 0);

    // Turn the data into a d3 hierarchy and calculate the sums.
    var root = d3.hierarchy(json)
        .sum(function(d) { return d.size; });
        // .sort(function(a, b) { return b.value - a.value; }); //disabled sorting to maintain taxonomic order

    // For efficiency, filter nodes to keep only those large enough to see.
    var nodes = partition(root).descendants()
        .filter(function(d) {
            return (d.x1 - d.x0 > 0.005); // 0.005 radians = 0.29 degrees
        });

    var path = vis.data([json]).selectAll("path")
        .data(nodes)
        .enter().append("svg:path")
        .attr("display", function(d) { return d.depth ? null : "none"; })
        .attr("d", arc)
        .attr("fill-rule", "evenodd")
        .style("fill", function(d) { return color((d.children ? d : d.parent).data.name); })
        .style("opacity", 1)
        .on("mouseover", mouseover);

    // Add the mouseleave handler to the bounding circle.
    d3.select("#container_" + diagram_id).on("mouseleave", mouseleave);

    // Get total size of the tree = value of root node from partition.
    totalSizes[diagram_id] = path.datum().value;
};

// Fade all but the current sequence, and show it in the breadcrumb trail.
function mouseover(d) {
    id = $(this).closest('.chart').data('id');
    totalSize = totalSizes[id];
    var chart = d3.select("#chart_" + id);

    var percentage = (100 * d.value / totalSize).toPrecision(3);
    var percentageString = percentage + "% (" + d.value + ")";
    if (percentage < 0.1) {
        percentageString = "< 0.1%";
    }

    d3.select("#percentage_" + id)
        .text(percentageString);

    d3.select("#explanation_" + id)
        .style("visibility", "");

    var sequenceArray = d.ancestors().reverse();
    sequenceArray.shift(); // remove root node from the array
    updateBreadcrumbs(sequenceArray, percentageString, id);

    // Fade all the segments.
    chart.selectAll("path")
        .style("opacity", 0.3);

    // Then highlight only those that are an ancestor of the current segment.
    chart.selectAll("path")
        .filter(function(node) {
            return (sequenceArray.includes(node));
        })
        .style("opacity", 1);
}

// Restore everything to full opacity when moving off the visualization.
function mouseleave(d) {
    id = $(this).closest('.chart').data('id');

    // Hide the breadcrumb trail
    d3.select("#trail_" + id)
        .style("visibility", "hidden");

    // Deactivate all segments during transition.
    d3.selectAll("path").on("mouseover", null);

    // Transition each segment to full opacity and then reactivate it.
    d3.selectAll("path")
        .transition()
        .duration(1000)
        .style("opacity", 1)
        .on("end", function() {
            d3.select(this).on("mouseover", mouseover);
        });

    d3.select("#explanation_" + id)
        .style("visibility", "hidden");
}

function initializeBreadcrumbTrail() {
    // Add the svg area.
    var trail = d3.select("#sequence_" + diagram_id).append("svg:svg")
        .attr("width", width)
        .attr("height", 50)
        .attr("id", "trail_" + diagram_id);

    // Add the label at the end, for the percentage.
    trail.append("svg:text")
        .attr("id", "endlabel_" + diagram_id)
        .style("fill", "#000");
}

// Generate a string that describes the points of a breadcrumb polygon.
function breadcrumbPoints(d, i) {
    var points = [];
    points.push("0,0");
    points.push(b.w + ",0");
    points.push(b.w + b.t + "," + (b.h / 2));
    points.push(b.w + "," + b.h);
    points.push("0," + b.h);
    if (i > 0) { // Leftmost breadcrumb; don't include 6th vertex.
        points.push(b.t + "," + (b.h / 2));
    }
    return points.join(" ");
}

// Update the breadcrumb trail to show the current sequence and percentage.
function updateBreadcrumbs(nodeArray, percentageString, id) {
    // Data join; key function combines name and depth (= position in sequence).
    var trail = d3.select("#trail_" + id)
        .selectAll("g")
        .data(nodeArray, function(d) { return d.data.name + d.depth; });

    // Remove exiting nodes.
    trail.exit().remove();

    // Add breadcrumb and label for entering nodes.
    var entering = trail.enter().append("svg:g");

    entering.append("svg:polygon")
        .attr("points", breadcrumbPoints)
        .style("fill", function(d) { return color((d.children ? d : d.parent).data.name); })

    entering.append("svg:text")
        .attr("x", (b.w + b.t) / 2)
        .attr("y", b.h / 2)
        .attr("dy", "0.35em")
        .attr("text-anchor", "middle")
        .text(function(d) { return d.data.name; });

    // Merge enter and update selections; set position for all nodes.
    entering.merge(trail).attr("transform", function(d, i) {
        return "translate(" + i * (b.w + b.s) + ", 0)";
    });

    // Now move and update the percentage at the end.
    d3.select("#trail_" + id).select("#endlabel_" + id)
        .attr("x", (nodeArray.length + 0.5) * (b.w + b.s))
        .attr("y", b.h / 2)
        .attr("dy", "0.35em")
        .attr("text-anchor", "middle")
        .text(percentageString);

    // Make the breadcrumb trail visible, if it's hidden.
    d3.select("#trail_" + id)
        .style("visibility", "");
}

function deleteVisualization(diagram_id) {
    d3.select("#chart_" + diagram_id).selectAll("*").remove();
    d3.select("#diagram_title_" + diagram_id).selectAll("*").remove();
}
