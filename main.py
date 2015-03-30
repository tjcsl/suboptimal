from graph import *
from tsp import *
import math

def rd(deg):
	return math.radians(deg)

def create_basic_graph():
	g = Graph()
	v1 = g.add_vertex("Fort Totten", rd(38.9518467675), rd(-77.0022030768), {'RD','GR','YL'}) # RD: B06, other: E06
	v2 = g.add_vertex("Gallery Place", rd(38.8983168097), rd(-77.0219153904), {'RD','GR','YL'}) # RD: B01, other: F01
	v3 = g.add_vertex("Metro Center", rd(38.8983144732), rd(-77.0280779971), {'RD','OR','SV','BL'}) # RD: A01, other: C01
	v4 = g.add_vertex("L'Enfant Plaza", rd(38.8848377279), rd(-77.021908484), {'GR','YL','OR','SV','BL'}) # GR/YL: F03, other: D03
	v5 = g.add_vertex("Stadium Armory", rd(38.8867090898), rd(-76.9770889014), {'OR','SV','BL'}) # D08
	v6 = g.add_vertex("Glenmont", rd(39.0617837655), rd(-77.0535573593), {'RD'}) # B11
	v7 = g.add_vertex("Shady Grove", rd(39.1199273249), rd(-77.1646273343), {'RD'}) # A15
	v8 = g.add_vertex("Pentagon", rd(38.8694627012), rd(-77.0537156734), {'BL','YL'}) # C07
	v9 = g.add_vertex("Branch Ave", rd(38.8264463483), rd(-76.9114642177), {'GR'}) # F11
	v10 = g.add_vertex("Greenbelt", rd(39.0111458605), rd(-76.9110575731), {'GR','YL'}) # E10
	v11 = g.add_vertex("Rosslyn", rd(38.8959790962), rd(-77.0709086853), {'BL','OR','SV'}) # C05


	g.connect(v1,v2,13,{'GR','YL','RD'},'ba')
	g.connect(v4,v2,3,{'GR','YL'},'ba')
	g.connect(v3,v2,2,{'RD'},'ba')
	g.connect(v4,v5,9,{'OR','SV','BL'},'ba')
	g.connect(v3,v4,5,{'OR','SV','BL'},'ba')
	g.connect(v1,v6,16,{'RD'},'ba')
	g.connect(v7,v3,36,{'RD'},'ba')
	g.connect(v8,v4,5,{'YL'},'ba')
	g.connect(v9,v4,19,{'GR'},'ba')
	g.connect(v1,v10,12,{'GR','YL'},'ba')
	g.connect(v11,v3,7,{'SV','OR','BL'},'ba')
	g.connect(v8,v11,5,{'BL'},'ba')

	return g

def main():
	g = create_basic_graph()
	print_connections(g)
	print("Best edges: %s" % do_best_edges(g))

main()