jQuery(function() {
    if (document.getElementById("higher_order_taxa_tree") != null) {
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
    }

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

    // Set the dimensions and margins of the diagram
    var width = parentDiv.clientWidth,
        height = Math.max(width * 0.5625, 500),
        margin = { left: 50, top: 10, bottom: 10, right: 50 },
        nodeRadius = 10,
        scale = 1;

    d3.select('#higher_order_taxa_tree')
        .attr('style', function() {
            return (width * 0.5625 > 500) ? "padding-bottom: 56.25%;" : "padding-bottom: 100%;";
        });

    // Append the SVG object to the parent div
    var svg = d3.select('#higher_order_taxa_tree')
        .append("svg")
        .attr('id', 'higher_order_taxa_svg')
        .attr("preserveAspectRatio", "xMinYMin meet")
        .attr("viewBox", "0 0 " + width + " " + height)
        .classed("svg-content", true);

    // Appends a 'group' element to 'svg'
    // Moves the 'group' element to the top left margin
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

    var i = 0,
        duration = 750,
        root;

    // // Declares a tree layout and assigns the size
    var treemap = d3.tree().size([1, 1]);

    // Assigns the data to a hierarchy using parent-child relationships
    root = d3.hierarchy(data, function(d) {
        return d.children;
    });
    root.x0 = height / 2;
    root.y0 = 0;

    // Collapse after the second level
    root.children.forEach(collapse);

    update(root);

    // Collapse the node and all it's children
    function collapse(d) {
        if(d.children) {
            d._children = d.children
            d._children.forEach(collapse)
            d.children = null
        }
    }

    function update(source) {
        // Assigns the x and y position for the nodes
        var treeData = treemap(root);

        // Calculate maximum number of hierarchy levels and resize tree
        var tree_height = treeData.height;

        treemap.size([
            500,
            Math.max(width - (margin.left + margin.right) - 100, tree_height * 150)
        ]);

        treeData = treemap(root);

        // Compute the new tree layout.
        var nodes = treeData.descendants(),
            links = treeData.descendants().slice(1);

        // Normalize for fixed-depth.
        nodes.forEach(function(d){ d.y = d.depth * 180});

        // ****************** Nodes section ***************************

        // Update the nodes...
        var node = mainGroup.selectAll('g.node')
            .data(nodes, function(d) {
                return d.id || (d.id = ++i);
            });

        // Enter any new modes at the parent's previous position.
        var nodeEnter = node.enter().append('g')
            .attr('class', 'node')
            .attr("transform", function(d) {
                return "translate(" + source.y0 + "," + source.x0 + ")";
            })
            .on('click', click);

        // Add Circle for the nodes
        nodeEnter.append('circle')
            .attr('class', 'node')
            .attr("r", nodeRadius)
            .style("fill", function(d) {
                return d._children ? "lightgrey" : "#fff";
            })
            .attr("stroke", '#616161')
            .attr("stroke-width", '3');

        var textGroup = nodeEnter.append('g')
            .append("a")
            .attr("xlink:href", function(d) {
                return "/higher_order_taxa/" + d.data.id + "/edit";
            });

        // Add labels for the nodes
        textGroup.append('text')
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

        // UPDATE
        var nodeUpdate = nodeEnter.merge(node);

        // Transition to the proper position for the node
        nodeUpdate.transition()
            .duration(duration)
            .attr("transform", function(d) {
                return "translate(" + d.y + "," + d.x + ")";
            });

        // Update the node attributes and style
        nodeUpdate.select('circle.node')
            .attr("r", nodeRadius)
            .style("fill", function(d) {
                return d._children ? "lightgrey" : "#fff";
            })
            .attr('cursor', 'pointer');

        // Remove any exiting nodes
        var nodeExit = node.exit().transition()
            .duration(duration)
            .attr("transform", function(d) {
                return "translate(" + source.y + "," + source.x + ")";
            })
            .remove();

        // On exit reduce the node circles size to 0
        nodeExit.select('circle')
            .attr('r', 1e-6);

        // On exit reduce the opacity of text labels
        nodeExit.select('text')
            .style('fill-opacity', 1e-6);

        // ****************** links section ***************************

        // Update the links...
        var link = mainGroup.selectAll('path.link')
            .data(links);

        // Enter any new links at the parent's previous position.
        var linkEnter = link.enter()
            .insert('path', "g")
            .attr("class", "link")
            .attr("fill", 'none')
            .attr("stroke", '#ccc')
            .attr('d', function(d){
                var o = {
                    x: source.x0,
                    y: source.y0
                };
                return diagonal(o, o)
            });

        // UPDATE
        var linkUpdate = linkEnter.merge(link);

        // Transition back to the parent element position
        linkUpdate.transition()
            .duration(duration)
            .attr('d', function(d) {
                return diagonal(d, d.parent)
            });

        // Remove any exiting links
        var linkExit = link.exit().transition()
            .duration(duration)
            .attr('d', function(d) {
                var o = {x: source.x, y: source.y};
                return diagonal(o, o)
            })
            .remove();

        // Store the old positions for transition.
        nodes.forEach(function(d){
            d.x0 = d.x;
            d.y0 = d.y;
        });

        // Creates a curved (diagonal) path from parent to the child nodes
        function diagonal(s, d) {
            path = `M ${s.y} ${s.x}
            C ${(s.y + d.y) / 2} ${s.x},
              ${(s.y + d.y) / 2} ${d.x},
              ${d.y} ${d.x}`;

            return path
        }

        // Toggle children on click.
        function click(d) {
            if (d.children) {
                d._children = d.children;
                d.children = null;
            } else {
                d.children = d._children;
                d._children = null;
            }
            update(d);
        }
    }
};