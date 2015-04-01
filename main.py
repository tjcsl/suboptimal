from graph import *
from tsp import *
from gtfs import *
import math
import pygtfs
import os.path
import copy
import pprint

def rd(deg):
	return math.radians(deg)

def calculate_headway_times():
	lines = {'Red': (6, 12, 6, 8, 16.5),
		'Orange': (6, 12, 6, 12, 20),
		'Silver': (6, 12, 6, 12, 20),
		'Yellow': (6, 12, 6, 12, 20),
		'Green': (6, 12, 6, 12, 20),
		'Blue': (12, 12, 12, 12, 20)} # AM Rush, Midday, PM Rush, Evening, Late Night
	headway_times = {}
	hrs_amrush = 4.5
	hrs_midday = 5.5
	hrs_pmrush = 4
	hrs_evening = 2.5
	hrs_latenight = 2.5 # Only go to midnight
	for line in lines:
		headway_times[line+'_A'] = (lines[line][0]*hrs_amrush + lines[line][1]*hrs_midday + lines[line][2]*hrs_pmrush + lines[line][3]*hrs_evening + lines[line][4]*hrs_latenight) / (hrs_amrush+hrs_midday+hrs_pmrush+hrs_evening+hrs_latenight)
		headway_times[line+'_B'] = headway_times[line+'_A']
	return headway_times

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
	v12 = g.add_vertex("Columbia Heights", rd(38.9278379675), rd(-77.0325521177), {'GR','YL'}) # E04
	v13 = g.add_vertex("Rhode Island Ave", rd(38.9210596891), rd(-76.9959369166), {'RD'}) # B04

	#g.connect(v1,v2,13,{'GR','YL','RD'},'ba')
	#g.connect(v4,v2,3,{'GR','YL'},'ba')
	g.connect(v2,v13,8,{'RD'},'ba')
	g.connect(v13,v1,5,{'RD'},'ba')
	g.connect(v2,v12,7,{'GR','YL'},'ba')
	g.connect(v12,v1,6,{'GR','YL'},'ba')
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
	wmata = load_database("wmata.zip")
	#g = create_basic_graph()
	g = parse_from_gtfs(wmata, limit_lines = ['RED','SILVER','BLUE','GREEN','ORANGE','YELLOW'])
	print_connections(g)
	#edges = do_best_edges(g,headway_times=calculate_headway_times())
	#print("Best edges: %s" % edges)
	print("Doing TSP...")
	print(do_do_tsp(g,headway_times=calculate_headway_times()))

if __name__ == '__main__':
	main()