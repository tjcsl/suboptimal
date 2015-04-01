from graph cimport *
from random import shuffle, randint
from libc.math cimport sqrt
from libc.stdlib cimport rand, srand, RAND_MAX
import itertools

cdef list reconstruct_path(dict came_from, Vertex current):
    total_path = [current]
    while current in came_from:
        current = came_from[current]
        total_path.append(current)
    return total_path

cdef tuple astar(Graph g, Vertex start, Vertex goal, dict headway_times):
    cdef set closedset = set(), openset = {start}
    cdef dict came_from = {}, g_score = {}, f_score = {}, current_lines = {}
    cdef Vertex current, neighbor
    cdef double tentative_g_score, transfer_time

    g_score[start] = 0
    f_score[start] = g_score[start] + g.sph_distance(start,goal)
    current_lines[start] = start.lines

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
            if not current_lines[neighbor]: # If not, penalize the g score by the average of the headway times / 2
                
                current_lines[neighbor] = current.lines.intersection(current.paths[neighbor].lines) # Reset the available lines
                transfer_time = 0
                for line in current_lines[neighbor]:
                    if line not in headway_times:
                        print("WARN: line %s not in headway_times DB - for more accurate transfer timing, supply a headway_times dict with line to average transfer time mapping" % line)
                        transfer_time += 5
                        continue

                    transfer_time += headway_times[line]/2

                transfer_time /= len(current_lines[neighbor])
                tentative_g_score += transfer_time
                #print("Had to transfer at %s to get to %s, transfer time is %f" % (current.name, neighbor.name, transfer_time))

            if neighbor not in openset or tentative_g_score < g_score[neighbor]:
                came_from[neighbor] = current
                g_score[neighbor] = tentative_g_score
                f_score[neighbor] = g_score[neighbor] + g.sph_distance(neighbor,goal)
                #print("Finished %s to %s, g_score = %f, f_score = %f" % (current.name, neighbor.name, g_score[neighbor], f_score[neighbor]))
                #print(current_lines[current])
                if neighbor not in openset:
                    openset.add(neighbor)

    raise Exception("No path exists between %s and %s" % (start, goal))

def do_astar(g,v1,v2,headway_times={}):
    return astar(g,v1,v2,headway_times)

cdef list best_edges(Graph g, int n=2, dict headway_times={}):
    cdef list edges = g.vertices, hubs = g.hubs(4), shortest_path
    cdef dict scores = {}
    cdef Vertex edge
    cdef Path p
    cdef double closest_distance, is_singular

    print('Best hubs: %s' % hubs)

    for edge in edges:      
        if len(edge.paths) == 1:
            is_singular = 10000.0
            closest_distance = max([p.distance for p in edge.paths.values()])
        else:
            is_singular = 0.0
            closest_distance = 0.0 # No advantage gained by the closest distance if there are is more than one path
        scores[edge] = is_singular + closest_distance*0.8 - sqrt(sum([(astar(g,edge,hub,headway_times)[1]-closest_distance)*len(hub.paths) for hub in hubs]))*0.2 # Make this significantly less bad
        print("Score for edge %s is %f" % (edge.name, scores[edge]))

    return sorted(edges, key=lambda v:scores[v])[::-1][:n]

def do_best_edges(g,n=2,headway_times={}):
    return best_edges(g,n,headway_times)

cpdef void print_connections(Graph g):
    cdef Vertex v
    cdef Path p

    for v in g.vertices:
        for p in v.paths.values():
            print('%s -> %s (dist: %d, lines %s)' % (v.name, p.destination.name, p.distance, p.lines))

cdef list find_initial_traversal(Graph g, Vertex start, Vertex end, dict headway_times = {}):
    cdef set closedset = set(), openset = g.paths(), backupset
    cdef Vertex current = start
    cdef Path p
    cdef list path = [start], current_paths, closestpath, minp
    cdef tuple astarres
    cdef bint next = False
    cdef double minlen
    cdef int i

    while (current != end) or openset:
        next = False
        backupset = set()
        #print(current,path,openset,closedset)
        if not openset:
            path.extend(astar(g, current, end, headway_times)[0][::-1][1:])
            return path

        current_paths = list(current.paths.values())
        shuffle(current_paths)
        for p in current_paths:
            if p in openset:
                if p.destination == end: # Try our best not to go to the end until the end
                    #print("Don't want to go to the end yet")
                    backupset.add(p) # Add it to the backupset, but use a different path if possible
                    continue
                current = p.destination
                openset.remove(p)
                openset.remove(p.otherdir)
                closedset.add(p)
                closedset.add(p.otherdir)
                path.append(current)
                next = True
                break

        if next:
            continue
        else:
            if backupset and backupset == openset: # The only one left is the end
                #print("I'm forced to go to the end :( 1")
                p = list(backupset)[0]
                current = p.destination
                openset.remove(p)
                openset.remove(p.otherdir)
                closedset.add(p)
                closedset.add(p.otherdir)
                path.append(current)
                continue

        # At this point, there are no open paths in neighbors, so choose the closest open path and A* to it
        minlen = float('inf')
        minp = []
        backupset = set()
        for p in openset:
            if p.destination == end: # Don't go to the end unless needed
                #print("Don't want to go to the end yet")
                backupset.add(p)
                continue
            astarres = astar(g,current,p.source,headway_times)
            if astarres[1] < minlen:
                minlen = astarres[1]
                minp = astarres[0][::-1]

        if not minp: # The only paths left are to the end
            #print("I'm forced to go to the end :( 2")
            minp = astar(g,current,list(backupset)[0],headway_times)

        #print("Taking astar last resort path %s" % minp)

        for p in openset.copy():
            if p.source in minp and p.destination in minp and minp.index(p.source) == minp.index(p.destination)-1: # Remove visited paths from openset
                openset.remove(p)
                openset.remove(p.otherdir)
                closedset.add(p)
                closedset.add(p.otherdir)

        path.extend(minp[1:])
        current = minp[-1]

    return path

def do_init_traverse(g, start, end, headway_times={}):
    return find_initial_traversal(g,start,end,headway_times)

cdef double calculate_time(Graph g, list path, headway_times={}):
    cdef double time = 0, transfer_time
    cdef set current_lines = path[0].lines
    cdef int i
    cdef Path p
    cdef Vertex current
    cdef str line

    for i in range(len(path)-1):
        #print(current_lines)
        current = path[i]
        p = current.paths[path[i+1]]
        current_lines = current_lines.intersection(p.lines)
        transfer_time = 0
        if not current_lines:
            print("Transfering %s -> %s" % (p.source, p.destination))
            for line in p.lines:
                if line not in headway_times:
                    print("WARN: line %s not in headway_times DB - for more accurate transfer timing, supply a headway_times dict with line to average transfer time mapping" % line)
                    transfer_time += 5
                    continue

                transfer_time += headway_times[line]/2

            transfer_time /= len(p.lines)
            current_lines = p.lines

        time += p.distance + transfer_time
        print("%s -> %s took %f" % (p.source, p.destination, p.distance + transfer_time))

    return time

cdef list do_tsp(g, headway_times = {}):
    cdef list edges = best_edges(g,n=3,headway_times=headway_times)
    cdef tuple startend
    cdef list initial_population = []

    srand(randint(0,RAND_MAX)) # Seed C random number generator with a python random number (only happens once, so not a big deal)

    for startend in itertools.permutations(edges,2):
        initial_population.append(find_initial_traversal(g, startend[0], startend[1], headway_times=headway_times))

    for pop in initial_population:
        print("Path with time %f: %s" % (calculate_time(g,pop,headway_times)/60.0,pop))

def do_do_tsp(g, headway_times = {}):
    return do_tsp(g,headway_times)