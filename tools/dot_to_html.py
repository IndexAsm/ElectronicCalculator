import sys
import re
import json
from pathlib import Path

inp = sys.argv[1]
out = sys.argv[2]

dot = Path(inp).read_text(errors="ignore")

EXE_NAMES = {"index", "index.exe", "./index", "build/index.exe"}
SYSTEM_HEADERS = {"iostream", "vector", "string", "map", "memory", "algorithm", "cstdio", "cstdlib", "cmath"}
include_re = re.compile(r'#include\s*[<"](.*?)[">]')

def norm(p):
    return str(Path(p).as_posix())

raw_edges = re.findall(r'"([^"]+)"\s*->\s*"([^"]+)"', dot)
nodes = set()
edges = []
for a, b in raw_edges:
    a, b = norm(a), norm(b)
    nodes.add(a); nodes.add(b)
    edges.append((a, b))

header_index = {}
for p in Path("src").rglob("*"):
    if p.suffix in [".h", ".hpp", ".c", ".cpp"]:
        header_index.setdefault(p.name, []).append(norm(p))

include_map = {}
for p in Path("src").rglob("*"):
    if p.suffix in [".c", ".cpp"]:
        try:
            txt = p.read_text(errors="ignore")
            include_map[norm(p)] = include_re.findall(txt)
        except Exception:
            include_map[norm(p)] = []

def resolve_header(name):
    if name in SYSTEM_HEADERS:
        return None
    if name in header_index:
        return header_index[name][0]
    return None

for src, incs in include_map.items():
    for inc in incs:
        target = resolve_header(inc)
        if target:
            edges.append((src, target))
            nodes.add(src); nodes.add(target)

def classify(n):
    name = Path(n).name
    if name in EXE_NAMES:
        return "exe"
    if name == "pch.hpp":
        return "pch"
    if n.endswith(".cpp"):
        return "cpp"
    if n.endswith(".c"):
        return "c"
    if n.endswith(".h") or n.endswith(".hpp"):
        return "header"
    if n.endswith(".asm"):
        return "asm"
    if n.endswith(".o"):
        return "obj"
    if name in SYSTEM_HEADERS:
        return "system"
    return "other"

connections = {n: [] for n in nodes}
for a, b in edges:
    connections.setdefault(a, []).append(b)
    connections.setdefault(b, []).append(a)

nodes_json = [{"id": n, "type": classify(n), "connections": connections.get(n, [])} for n in nodes]
links_json = [{"source": a, "target": b} for a, b in edges]

html = f"""<!DOCTYPE html>
<html><head><meta charset="utf-8"><title>Build Graph</title>
<style>body{{margin:0;overflow:hidden;font-family:monospace;}}
#panel{{position:absolute;top:10px;right:10px;width:300px;background:rgba(20,20,20,0.95);color:white;padding:10px;border-radius:8px;font-size:12px;}}</style>
</head><body>
<div id="panel">Click a node</div>
<svg width="100%" height="100%"></svg>
<script src="https://d3js.org/d3.v7.min.js"></script>
<script>
const nodes = {json.dumps(nodes_json)};
const links = {json.dumps(links_json)};
const color = {{cpp:"#4a90e2",c:"#7ed321",asm:"#d0021b",header:"#f5a623",pch:"#bd10e0",exe:"#ffd700",obj:"#888",system:"#555",other:"#aaa"}};
const svg = d3.select("svg");
const width = window.innerWidth, height = window.innerHeight;
svg.attr("viewBox", [0,0,width,height]);
const g = svg.append("g");
svg.call(d3.zoom().on("zoom", e => g.attr("transform", e.transform)));
const link = g.selectAll("line").data(links).enter().append("line").attr("stroke","#999").attr("stroke-opacity",0.5);
function reset(){{node.select("circle").attr("opacity",1);link.attr("stroke","#999").attr("opacity",0.4);}}
function showInfo(d){{document.getElementById("panel").innerHTML=`<b>${{d.id}}</b><br>Type: ${{d.type}}<br><br>Connections:<br>${{d.connections.map(x=>"-> "+x).join("<br>")}}`;}}
function highlight(d){{reset();node.select("circle").attr("opacity",n=>n.id===d.id||d.connections.includes(n.id)?1:0.2);
link.attr("stroke",l=>l.source.id===d.id||l.target.id===d.id?"#ffcc00":"#999").attr("opacity",l=>l.source.id===d.id||l.target.id===d.id?1:0.2);}}
const node = g.selectAll("g").data(nodes).enter().append("g")
.on("click",(event,d)=>{{highlight(d);showInfo(d);if(event.shiftKey){{window.open("vscode://file/"+encodeURIComponent(d.id),"_blank");}}}})
.call(d3.drag().on("start",dragstart).on("drag",drag).on("end",dragend));
node.append("circle").attr("r",d=>d.type==="exe"?16:6).attr("fill",d=>color[d.type]||"#999");
node.append("text").text(d=>d.id).attr("x",10).attr("y",4).attr("font-size","11px");
const sim = d3.forceSimulation(nodes).force("link",d3.forceLink(links).id(d=>d.id).distance(90)).force("charge",d3.forceManyBody().strength(-250)).force("center",d3.forceCenter(width/2,height/2));
sim.on("tick",()=>{{link.attr("x1",d=>d.source.x).attr("y1",d=>d.source.y).attr("x2",d=>d.target.x).attr("y2",d=>d.target.y);node.attr("transform",d=>`translate(${{d.x}},${{d.y}})`);}});
function dragstart(event,d){{if(!event.active)sim.alphaTarget(0.3).restart();d.fx=d.x;d.fy=d.y;}}
function drag(event,d){{d.fx=event.x;d.fy=event.y;}}
function dragend(event,d){{if(!event.active)sim.alphaTarget(0);d.fx=null;d.fy=null;}}
</script></body></html>
"""
Path(out).write_text(html)
print("Generated:", out)
