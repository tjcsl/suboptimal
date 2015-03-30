from graph cimport *
from libc.math cimport sqrt

cdef list reconstruct_path(dict came_from, Vertex current):
	total_path = [current]
	while current in came_from:
		current = came_from[current]
		total_path.append(current)
	return total_path

cdef tuple astar(Graph g, Vertex start, Vertex goal):
	cdef set closedset = set(), openset = {start}
	cdef dict came_from = {}, g_score = {}, f_score = {}, current_lines = {}
	cdef Vertex current, neighbor
	cdef double tentative_g_score

	g_score[start] = 0
	f_score[start] = g_score[start] + g.sph_distance(start,goal)
	current_lines[start] = start.lines

	#print(current_lines)

	while openset:
		current = min(openset, key=lambda v:f_score[v])
		if current == goal:
			#print('Path found with g_score %f' % g_score[current])
			return (reconstruct_path(came_from, goal), g_score[current])

		openset.remove(current)
		closedset.add(current)
		for neighbor in g.neighbors(current):
			if neighbor in closedset:
				continue

			tentative_g_score = g_score[current] + g.distance(current,neighbor)
			current_lines[neighbor] = current.paths[neighbor].lines.intersection(current_lines[current]) # At the transfer, can I stay on the same line?
			if not current_lines[neighbor]: # If not, penalize the g score by an approximate 5 minute transfer time
				#print("Had to transfer at %s" % current.name)
				tentative_g_score += 5
				current_lines[neighbor] = neighbor.lines # And reset the available lines

			if neighbor not in openset or tentative_g_score < g_score[neighbor]:
				came_from[neighbor] = current
				g_score[neighbor] = tentative_g_score
				f_score[neighbor] = g_score[neighbor] + g.sph_distance(neighbor,goal)
				#print("Finished %s to %s, g_score = %f, f_score = %f" % (current.name, neighbor.name, g_score[neighbor], f_score[neighbor]))
				#print(current_lines[current])
				if neighbor not in openset:
					openset.add(neighbor)

	return tuple()

def do_astar(g,v1,v2):
	return astar(g,v1,v2)

cdef list best_edges(Graph g, int n = 2):
	cdef list edges	= g.leaf_vertices(), hubs = g.hubs(), shortest_path
	cdef dict scores = {}
	cdef Vertex edge
	cdef double closest_distance

	print('Best hubs: %s' % hubs)

	for edge in edges:
		closest_distance = list(edge.paths.values())[0].distance
		scores[edge] = closest_distance*0.8 - sqrt(sum([(astar(g,edge,hub)[1]-closest_distance)*len(hub.paths) for hub in hubs]))*0.2 # Make this significantly less bad
		print("Score for edge %s is %f" % (edge.name, scores[edge]))

	return sorted(edges, key=lambda v:scores[v])[::-1][:n]

def do_best_edges(g,n=2):
	return best_edges(g,n)

cpdef void print_connections(Graph g):
	cdef Vertex v
	cdef Path p

	for v in g.vertices:
		for p in v.paths.values():
			print('%s -> %s (dist: %d)' % (v.name, p.destination.name, p.distance))

