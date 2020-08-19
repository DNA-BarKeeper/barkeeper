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
    var width = 600,
        height = 500,
        nodeRadius = 12,
        margin = { left: 50, top: 10, bottom: 10, right: 50 };

    var svg = d3.select('#higher_order_taxa_tree')
        .append('svg')
        .attr('id', 'higher_order_taxa_svg')
        .attr("width", width)
        .attr("height", height);

    var mainGroup = svg.append('g')
        .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')');

    var tree = d3.tree()
        .size([
            height - (margin.bottom + margin.top),
            width - (margin.left + margin.right) - 100,
        ]);

    // //  assigns the data to a hierarchy using parent-child relationships
    var nodes = d3.hierarchy(data, function(d) {
        return d.children;
    });

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
