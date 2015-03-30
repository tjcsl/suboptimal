from graph import *
from tsp import *
import math

def rd(deg):
	return math.radians(deg)

def create_basic_graph():
	g = Graph()
	v1 = g.add_vertex("Fort Totten", rd(38.9518467675), rd(-77.0022030768), {'RD','GR','YL'})
	v2 = g.add_vertex("Gallery Place", rd(38.8983168097), rd(-77.0219153904), {'RD','GR','YL'})
	v3 = g.add_vertex("Metro Center", rd(38.8983144732), rd(-77.0280779971), {'RD','OR','SV','BL'})
	v4 = g.add_vertex("L'Enfant Plaza", rd(38.8848377279), rd(-77.021908484), {'GR','YL','OR','SV','BL'})
	v5 = g.add_vertex("Stadium Armory", rd(38.8867090898), rd(-76.9770889014), {'OR','SV','BL'})

	g.connect(v1,v2,13,{'GR','YL','RD'},'ba')
	g.connect(v4,v2,3,{'GR','YL'},'ba')
	g.connect(v3,v2,2,{'RD'},'ba')
	g.connect(v4,v5,9,{'OR','SV','BL'},'ba')
	g.connect(v3,v4,5,{'OR','SV','BL'},'ba')

	return g

def main():
	g = create_basic_graph()
	#print_connections(g)
	v1 = g.get_vertex_by_name("Stadium Armory")
	v2 = g.get_vertex_by_name("Fort Totten")
	print(do_best_edges(g))

main()