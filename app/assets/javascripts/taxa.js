jQuery(function() {
    if (document.getElementById("taxonomy_tree") != null) {
        initialize_buttons();

        $("#taxonomy_root_select").on("change", () => $.ajax({
            type: "GET",
            contentType: "application/json; charset=utf-8",
            url: 'taxa/taxonomy_tree',
            dataType: 'json',
            data: {
                root_id: $('#taxonomy_root_select option:selected').val()
            },
            success: function (data) {
                remove_selected_taxon_info();
                deleteVisualization('#taxonomy_tree');

                drawTaxonomy(data[0]);
            },
            error: function (_result) {
                console.error("Error getting data.");
            }
        }));
    }

    $('#taxon_parent_name').autocomplete({
        source: $('#taxon_parent_name').data('autocomplete-source')});

    $('#taxon_project_ids').chosen({
        allow_single_deselect: true,
        no_results_text: 'No results matched'
    });

    $('#taxon_search').autocomplete({
        source: $('#taxon_search').data('autocomplete-source')});

    $('#orphans').DataTable({
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#orphans').data('source'),
        "columnDefs": [
            { "orderable": false, "targets": 5 }
        ],
        "order": [ 0, 'asc' ]
    });
});

function initialize_buttons() {
    disableButton($("#center_root"), "Please load a taxonomy first");
    disableButton($("#reset_tree_pos"), "Please load a taxonomy first");

    disableButton($("#center_selected_node"), "Please select a taxon first");

    disableButton($("#edit_taxon"), "Please select a taxon first");
    disableButton($("#delete_taxon"), "Please select a taxon first");
}

function remove_selected_taxon_info() {
    d3.select('#taxon_info').selectAll("p").remove();
    d3.select('#specimen_list').html('');
    d3.select('#specimen_list').append('p').text('Please select a taxon.');
}

// Main function to draw and set up the visualization, once we have the data.
function drawTaxonomy(data) {
    var parentDiv = document.getElementById("taxonomy_tree");

    // Set the dimensions and margins of the diagram
    var width = parentDiv.clientWidth - 17,
        height = 710,
        margin = { left: 50, top: 10, bottom: 10, right: 50 },
        nodeRadius = 10,
        scale = 1;

    var selected_node = null;

    // Append the SVG object to the parent div
    var svg = d3.select('#taxonomy_tree')
        .append("svg")
        .attr('id', 'taxa_svg')
        .attr('width', "100%")
        .attr('height', height)
        .attr("preserveAspectRatio", "xMinYMin slice")
        .attr("viewBox", "0 0 " + width + " " + height)
        .classed("svg-content", true);

    // Appends a 'group' element to 'svg' and moves it to the top left margin
    var mainGroup = svg.append('g')
        .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')');

    // Enable zoom & pan
    var zoom = d3.zoom()
        .on("zoom", function() {
            mainGroup.attr("transform", d3.event.transform)
        });

    svg.call(zoom);

    var taxon_text = d3.select('#taxon_info').append('p').attr('id', 'taxon_text');

    var i = 0,
        duration = 750,
        root;

    // Declares a tree layout and assigns the size
    var treemap = d3.tree().separation(function(a, b) { return a.parent == b.parent ? 3 : 2; }).size([width, height]);

    // Assigns the data to a hierarchy using parent-child relationships
    root = d3.hierarchy(data, function(d) {
        return d.children;
    });
    root.x0 = height / 2;
    root.y0 = 0;

    root.loaded = true;

    update(root);

    centerNode(root);

    enableButton($("#center_root"), "Center root node");
    enableButton($("#reset_tree_pos"), "Align tree to top left");

    // Button to reset zoom and reset tree to top left
    d3.select("#reset_tree_pos")
        .on("click", function() {
            zoom.transform(svg, d3.zoomIdentity.translate(margin.left, margin.top).scale(scale));
        });

    // Button to reset zoom and center root node
    d3.select("#center_root")
        .on("click", function() {
            centerNode(root);
        });

    // Button to reset zoom and center root node
    d3.select("#center_selected_node")
        .on("click", function() {
            if (selected_node !== null) {
                centerNode(selected_node);
            }
        });

    d3.select('#start_search')
        .on("click", function() { startTaxonSearch() });

    document.getElementById('taxon_search')
        .addEventListener("keydown", function (e) {
        if (e.code === "Enter") {
            startTaxonSearch();
        }
    });

    function startTaxonSearch() {
        var taxon_name = document.getElementById('taxon_search').value;

        $.ajax({
            type: "GET",
            contentType: "application/json; charset=utf-8",
            url: 'taxa/find_ancestry?taxon_name=' + taxon_name,
            dataType: 'text',
            processData: false,
            success: function (ancestry) {
                var ancestor_ids = ancestry.split('/');
                open_path(root, ancestor_ids, taxon_name);
            },
            error: function (_result) {
                console.error("Error getting data.");
            }
        });
    }

    function update(source) {
        var levelHeight = [1];
        var childCount = function(level, n) {
            if (n.children && n.children.length > 0) {
                if (levelHeight.length <= level + 1) levelHeight.push(0);

                levelHeight[level + 1] += n.children.length;
                n.children.forEach(function(d) {
                    childCount(level + 1, d);
                });
            }
        };
        childCount(0, root);
        var newHeight = d3.max(levelHeight) * 50;

        treemap = treemap.size([newHeight, width]);

        treeData = treemap(root);

        // Compute the new tree layout.
        var nodes = treeData.descendants(),
            links = treeData.descendants().slice(1);

        // Normalize for fixed-depth.
        nodes.forEach(function(d) { d.y = d.depth * 180 });

        // ****************** Nodes section ***************************

        // Update the nodes...
        var node = mainGroup.selectAll('g.node')
            .data(nodes, function(d) {
                return d.id || (d.id = ++i);
            });

        // Enter any new nodes at the parent's previous position.
        var nodeEnter = node.enter().append('g')
            .attr('class', 'node')
            .attr("transform", function(_d) {
                return "translate(" + source.y0 + "," + source.x0 + ")";
            })
            .on("mouseover", function(d) {
                d3.select(this).style("cursor", "pointer");
            })
            .on("mouseout", function(d) {
                d3.select(this).style("cursor", "default");
            });

        // Add circle for the nodes
        nodeEnter.append('circle')
            .attr("r", nodeRadius)
            .attr('id', function(d) { return "node_" + d.data.id })
            .classed("closed", function(d) { return d._children })
            .style("fill", function(d) {
                return d.data.has_children ? "lightgrey" : "#fff";
            })
            .attr("stroke", '#616161')
            .attr("stroke-width", '3')
            .on('click', click);

        nodeEnter.append('text')
            .attr('id', function(d) { return "label_" + d.data.id })
            .text(function (d) {
                return d.data.scientific_name;
            })
            .attr('y', function (d) {
                return d.data.has_children ?
                    nodeRadius * 2 : 0;
            })
            .attr('x', function (d) {
                return d.data.has_children ?
                    0 : nodeRadius * 1.5;
            })
            .attr("dy", '.35em')
            .attr("text-anchor", function (d) {
                return d.data.has_children ?
                    'middle' : 'left';
            })
            .attr("fill-opacity", 1)
            .style('font', '14px sans-serif')
            .on('click', function(d) {
                // Display taxon info in top left div
                var text = "<b>Scientific name:</b> " + htmlSafe(d.data.scientific_name) + "<br>";
                if (d.data.taxonomic_rank) text += "<b>Taxonomic rank</b>: " + htmlSafe(d.data.taxonomic_rank) + "<br>";
                if (d.data.synonym) text += "<b>Synonym</b>: " + htmlSafe(d.data.synonym) + "<br>";
                if (d.data.common_name) text += "<b>Common name:</b> " + htmlSafe(d.data.common_name) + "<br>";
                if (d.data.author) text += "<b>Author:</b> " + htmlSafe(d.data.author) + "<br>";
                if (d.data.comment) text += "<b>Comment:</b> " + htmlSafe(d.data.comment) + "<br>";
                taxon_text.html(text);

                // Set correct taxon edit and destroy links and enable buttons
                var taxon_edit_link = d3.select('#edit_taxon').attr('href').replace(/(.*\/)(\d+)(\/.*)/, "$1" + d.data.id + "$3");
                d3.select('#edit_taxon').attr('href', taxon_edit_link);
                enableButton($('#edit_taxon'), 'Edit entry in a new tab');

                var taxon_delete_link = d3.select('#delete_taxon').attr('href').replace(/(.*\/)(\d+)/, "$1" + d.data.id);
                d3.select('#delete_taxon').attr('href', taxon_delete_link);
                enableButton($('#delete_taxon'), 'Delete taxon entry');

                selected_node = d;
                enableButton($('#center_selected_node'), 'Center currently selected node');

                // Display list of specimen associated with this taxon
                display_specimen_Data(d);
            });

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
                return d.data.has_children ? "lightgrey" : "#fff";
            })
            .attr('cursor', 'pointer');

        // Remove any exiting nodes
        var nodeExit = node.exit().transition()
            .duration(duration)
            .attr("transform", function(_d) {
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
            .data(links, function(d) { return d.id; });

        // Enter any new links at the parent's previous position.
        var linkEnter = link.enter()
            .insert('path', "g")
            .attr("class", "link")
            .attr("fill", 'none')
            .attr("stroke", 'lightgrey')
            .attr("stroke-width", '2px')
            .attr('d', function(_d){
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
        link.exit().transition()
            .duration(duration)
            .attr('d', function(_d) {
                var o = {x: source.x, y: source.y};
                return diagonal(o, o)
            })
            .remove();

        // Store the old positions for transition.
        nodes.forEach(function(d){
            d.x0 = d.x;
            d.y0 = d.y;
        });
    }

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
        var circle = d3.select(this);

        var promise = get_child_data(d);

        if(promise !== undefined) circle.classed("spinner",true);

        promise !== undefined ? $.when(promise).done(function() {
            circle.classed("spinner",false);
            toggle(d);
        }.bind(this)) : toggle(d);
    }

    function centerNode(source) {
        x = -source.y0;
        y = -source.x0;
        x = x  + $("#taxa_svg").width() / 2; // Use current width of SVG
        y = y + height / 2;

        d3.select('g').transition()
            .duration(duration)
            .attr("transform", "translate(" + x + "," + y + ")scale(" + scale + ")");
        zoom.transform(svg, d3.zoomIdentity.translate(x, y).scale(scale));
    }

    //	Toggle children on click.
    function toggle(d) {
        if (d.children) {
            d._children = d.children;
            d.children = null;
        } else {
            d.children = d._children;
            d._children = null;
        }
        update(d);
        centerNode(d);
    }

    function get_child_data(d) {
        if(d.loaded !== undefined)
            return;

        var newNodes = [];

        var promise = $.ajax({
            url: "taxa/taxonomy_tree?parent_id=" + d.data.id,
            dataType: 'json',
            type: 'GET',
            cache: false,
            success: function(responseJson) {
                if(responseJson.length === 0)
                    return;

                responseJson.forEach(function(element) {
                    var newNode = d3.hierarchy(element);
                    newNode.depth = d.depth + 1;
                    newNode.height = d.height - 1;
                    newNode.parent = d;

                    newNodes.push(newNode);
                });

                if (d.children) {
                    newNodes.forEach(function(node) {
                        d.children.push(node);
                        d.data.children.push(node.data);
                    })
                }
                else {
                    d._children = [];
                    d.data._children = [];

                    newNodes.forEach(function(node) {
                        d._children.push(node);
                        d.data._children.push(node.data);
                    })
                }

                d.loaded = true;
            }
        });

        return promise; //return a promise if async. requests
    }

    function display_specimen_Data(d) {
        $.ajax({
            url: "taxa/" + d.data.id + "/associated_specimen",
            dataType: 'json',
            type: 'GET',
            cache: false,
            success: function(data) {
                var ul = "<ul class=\"list-group list-group-flush\">";
                data.forEach(function(element) {
                    ul += "<li class=\"list-group-item\"><a href='individuals/" + element.id + "/edit' target='_blank'>" + element.specimen_id + "</a></li>";
                });
                ul += "</ul>";

                d3.select('#specimen_list').html(ul);
            }
        });
    }

    function open_path(node, ancestor_ids, searched_name) {
        var ancestor_id = ancestor_ids.shift();

        if (parseInt(node.data.id) === parseInt(ancestor_id)) {
            // Avoid endless loop when node is already opened
            if (ancestor_ids.length !== 1) {
                open_path(node, ancestor_ids, searched_name);
            }
        }
        else {
            node.children.forEach(function (child_node) {
                if (typeof ancestor_id !== 'undefined') {
                    if (parseInt(child_node.data.id) === parseInt(ancestor_id)) {
                        if (!child_node.children) {
                            // Children were not loaded yet
                            var node_circle = d3.select("#node_" + ancestor_id);

                            var promise = get_child_data(child_node);

                            if (promise !== undefined) node_circle.classed("spinner", true);

                            promise !== undefined ? $.when(promise).done(function () {
                                node_circle.classed("spinner", false);
                                toggle(child_node);
                                open_path(child_node, ancestor_ids, searched_name);
                            }.bind(node_circle)) : toggle(child_node);
                        } else {
                            open_path(child_node, ancestor_ids, searched_name);
                        }
                    }
                }
                else {
                   if (child_node.data.scientific_name === searched_name) {
                       // Center and select node
                       centerNode(child_node);
                       d3.select("#label_" + child_node.data.id).dispatch('click');
                   }
                }
            });
        }
    }
}
