jQuery(function() {
    $.ajax({
        type: "GET",
        contentType: "application/json; charset=utf-8",
        url: 'higher_order_taxa/hierarchy_tree',
        dataType: 'json',
        processData: false,
        success: function (data) {
            drawHierarchy(data[0]);
        },
        error: function (result) {
            console.error("Error getting data.");
        }
    });

    $('#higher_order_taxon_marker_ids').chosen({
        allow_single_deselect: true,
        no_results_text: 'No results matched'
    });

    $('#higher_order_taxon_project_ids').chosen({
        allow_single_deselect: true,
        no_results_text: 'No results matched'
    });

    return $('#higher_order_taxon_parent_id').autocomplete({
        source: $('#higher_order_taxon_parent_id').data('autocomplete-source')
    });
});

// Main function to draw and set up the visualization, once we have the data.
function drawHierarchy(data) {
    var parentDiv = document.getElementById("higher_order_taxa_tree");

    var width = parentDiv.clientWidth,
        height = parentDiv.clientHeight,
        nodeRadius = 10,
        scale = 1,
        margin = { left: 50, top: 10, bottom: 10, right: 50 };

    var svg = d3.select('#higher_order_taxa_tree')
        .append('svg')
        .attr('id', 'higher_order_taxa_svg')
        .attr("preserveAspectRatio", "xMinYMin meet")
        .attr("viewBox", "0 0 " + width + " " + height)
        .classed("svg-content", true);

    var mainGroup = svg.append('g')
        .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')');

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
        zoom.transform(svg, d3.zoomIdentity.translate(margin.left, margin.top).scale(scale));
    });

    var tree = d3.tree()
        .size([
            height - (margin.bottom + margin.top),
            width - (margin.left + margin.right) - 100,
        ]);

    // Assigns the data to a hierarchy using parent-child relationships
    var nodes = d3.hierarchy(data, function(d) {
        return d.children;
    });

    nodes = tree(nodes);

    // Calculate maximum number of hierarchy levels and resize tree
    var tree_height = nodes.height;

    tree.size([
            height - (margin.bottom + margin.top),
            Math.max(width - (margin.left + margin.right) - 100, tree_height * 150)
        ]);

    // Recalculate nodes
    nodes = tree(nodes);

    var linksGenerator = d3.linkHorizontal() // d3.linkVertical()
        .source(function(d) {return [d.parent.y, d.parent.x];})
        .target(function(d) {return [d.y, d.x];});

    mainGroup.selectAll('path')
        .data(nodes.descendants().slice(1))
        .enter()
        .append('path')
        .attr("d", linksGenerator)
        .attr("fill", 'none')
        .attr("stroke", '#ccc');

    var circleGroups = mainGroup.selectAll('g')
        .data(nodes.descendants())
        .enter()
        .append('g')
        .attr('transform', function (d) {
            return 'translate(' + d.y + ',' + d.x + ')';
        })
        .append("a")
        .attr("xlink:href", function(d) {
            return "/higher_order_taxa/" + d.data.id + "/edit";
        });

    circleGroups.append('circle')
        .attr("r", nodeRadius)
        .attr("fill", '#fff')
        .attr("stroke", '#616161')
        .attr("stroke-width", '3');

    circleGroups.append('text')
        .text(function (d) {
            return d.data.name;
        })
        .attr('y', function (d) {
            return d.children || d._children ?
                nodeRadius * 2 : 0;
        })
        .attr('x', function (d) {
            return d.children || d._children ?
                0 : nodeRadius * 1.5;
        })
        .attr("dy", '.35em')
        .attr("text-anchor", function (d) {
            return d.children || d._children ?
                'middle' : 'left';
        })
        .attr("fill-opacity", 1)
        .style('font', '14px sans-serif');
};
