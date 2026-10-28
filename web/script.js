
const svg = d3.select("#tree");
const group = svg.append("g");

const colors = {
    Program: "#2563eb",
    Block: "#64748b",
    Number: "#16a34a",
    Variable: "#0d9488",
    BinaryOp: "#9333ea",
    UnaryOp: "#9333ea",
    Declaration: "#ea580c",
    Assignment: "#ea580c",
    If: "#dc2626",
    While: "#dc2626",
    Print: "#ca8a04",
    Return: "#ca8a04"
};

let root;

const zoom = d3.zoom()
    .scaleExtent([0.2, 3])
    .on("zoom", event => {
        group.attr("transform", event.transform);
    });

svg.call(zoom);

function drawTree() {
    const tree = d3.tree().nodeSize([65, 190]);
    tree(root);

    const links = group.selectAll(".link")
        .data(root.links(), d => d.target.data.id);

    links.exit().remove();

    links.enter()
        .append("path")
        .attr("class", "link")
        .merge(links)
        .attr("d", d => {
    const startX = d.source.y + 70;
    const startY = d.source.x;

    const endX = d.target.y - 70;
    const endY = d.target.x;

    return d3.linkHorizontal()({
        source: [startX, startY],
        target: [endX, endY]
    });
});

    const nodes = group.selectAll(".node")
        .data(root.descendants(), d => d.data.id);

    nodes.exit().remove();

    const newNodes = nodes.enter()
        .append("g")
        .attr("class", "node");

    newNodes.append("rect")
        .attr("x", -70)
        .attr("y", -20)
        .attr("width", 140)
        .attr("height", 40)
        .attr("rx", 6);

    newNodes.append("text")
        .attr("text-anchor", "middle")
        .attr("dy", "4");

    const allNodes = newNodes.merge(nodes);

    allNodes.attr("transform",
        d => `translate(${d.y},${d.x})`);

    allNodes.select("rect")
        .attr("fill",
            d => colors[d.data.type] || "#555");

    allNodes.select("text")
        .text(d => {
            let label = d.data.type;

            if (d.data.value) {
                label += ": " + d.data.value;
            }

            return label;
        });

    allNodes.on("click", (event, d) => {
        if (d.children) {
            d._children = d.children;
            d.children = null;
        } else {
            d.children = d._children;
            d._children = null;
        }

        drawTree();
    });
}

function expandAll(node) {
    if (node._children) {
        node.children = node._children;
        node._children = null;
    }

    if (node.children) {
        node.children.forEach(expandAll);
    }
}

function collapseAll(node) {
    if (node.children) {
        node.children.forEach(collapseAll);
        node._children = node.children;
        node.children = null;
    }
}

function resetView() {
    const height = document.querySelector(
        "#tree-container").clientHeight;

    svg.transition()
        .duration(300)
        .call(zoom.transform,
            d3.zoomIdentity.translate(120, height / 2)
                .scale(0.8));
}

document.querySelector("#reset").onclick = resetView;

document.querySelector("#expand").onclick = () => {
    expandAll(root);
    drawTree();
};

document.querySelector("#collapse").onclick = () => {
    collapseAll(root);
    drawTree();
};

fetch("ast.json")
    .then(response => {
        if (!response.ok) {
            throw new Error("Cannot load ast.json");
        }
        return response.json();
    })
    .then(data => {
        let id = 0;
        root = d3.hierarchy(data);

        root.eachBefore(d => {
            d.data.id = id++;
        });

        drawTree();
        resetView();

        document.querySelector("#status").textContent =
            "AST loaded successfully";
    })
    .catch(error => {
        document.querySelector("#status").textContent =
            error.message;
    });