import pygtfs
import pprint
from graph cimport *
import os
from libc.math cimport M_PI

cdef rd(double deg):
    return deg * (180.0/M_PI)

def load_database(f):
    generatedb = False
    dbfile = os.path.splitext(f)[0] + '.db'
    if not os.path.exists(dbfile):
        generatedb = True

    sched = pygtfs.Schedule(dbfile)
    if generatedb:
        pygtfs.append_feed(sched, f)
    return sched

def parse_from_gtfs(gt, limit_lines=[]):
    if not limit_lines:
        routes = gt.routes
    else:
        routes = [gt.routes_by_id(i)[0] for i in limit_lines]

    stops = {}
    connections = {}

    g = Graph()
    print("Generating stop list...")
    for route in routes:
        print("Finding longest trip for route %s..." % route.route_short_name)
        trip = max(route.trips, key=lambda t:len(t.stop_times))
        print("Generating list of stops for route %s..." % route.route_short_name)
        for stop in trip.stop_times: # Choose a midday trip for best route accuracy
            stop = stop.stop
            if stop.stop_name in stops:
                stops[stop.stop_name][3].add(route.route_short_name)
            else:
                stops[stop.stop_name] = ([stop.stop_name, rd(stop.stop_lat), rd(stop.stop_lon), set([route.route_short_name]), None])

    print("Generating connection list...")
    for route in routes:
        print("Finding longest trip for route %s..." % route.route_short_name)
        trip = max(route.trips, key=lambda t:len(t.stop_times))
        unordered_times = trip.stop_times
        times = sorted(unordered_times, key=lambda t:t.stop_sequence)
        print("Connecting tree for route %s..." % route.route_short_name)
        for stop in range(len(times)):
            current_time = times[stop].departure_time
            if stop != len(times)-1: # not last stop
                next_time = times[stop+1].departure_time
                if times[stop].stop.stop_name not in connections:
                    connections[times[stop].stop.stop_name] = {times[stop+1].stop.stop_name:(next_time-current_time,set([route.route_short_name]),'n')}
                else:
                    if times[stop+1].stop.stop_name not in connections[times[stop].stop.stop_name]:
                        connections[times[stop].stop.stop_name][times[stop+1].stop.stop_name] = (next_time-current_time,set([route.route_short_name]),'n')
                    else:
                        connections[times[stop].stop.stop_name][times[stop+1].stop.stop_name][1].add(route.route_short_name)
            if stop != 0: # Not first stop
                if times[stop].stop.stop_name not in connections:
                    connections[times[stop].stop.stop_name] = {times[stop-1].stop.stop_name:(current_time-last_time,set([route.route_short_name]),'p')}
                else:
                    if times[stop-1].stop.stop_name not in connections[times[stop].stop.stop_name]:
                        connections[times[stop].stop.stop_name][times[stop-1].stop.stop_name] = (current_time-last_time,set([route.route_short_name]),'p')
                    else:
                        connections[times[stop].stop.stop_name][times[stop-1].stop.stop_name][1].add(route.route_short_name)

            last_time = current_time
    print(stops)
    print(stops.keys())
    pprint.pprint(connections)
    print("Pruning tree...")
    for connection in list(connections.keys()):
        if len(connections[connection]) == 2: # Not end or transfer, generally not important
            c = list(connections[connection].keys())
            first = [c for c in connections[connection].keys() if connections[connection][c][2] == 'p'][0]
            second = [c for c in connections[connection].keys() if connections[connection][c][2] == 'n'][0]
            if connections[connection][first][1] != connections[connection][second][1]:
                continue # Don't prune this point, lines change

            if second in connections[first]: # This shouldn't happen, in this case, an intermediate point is required, but ignore that for now
                continue # Leave this one point
            else:
                connections[first][second] = (connections[connection][first][0] + connections[connection][second][0], connections[connection][first][1], 'n')
                connections[second][first] = (connections[connection][first][0] + connections[connection][second][0], connections[connection][first][1], 'p')
            del connections[connection]
            del connections[first][connection]
            del connections[second][connection]
            del stops[connection]

    pprint.pprint(stops)
    pprint.pprint(connections)

    print("Generating graph...")
    for stop in stops:
        stops[stop][4] = g.add_vertex(*stops[stop][0:4])

    for stop in stops:
        for connection in connections[stop]:
            if connections[stop][connection][2] != 'n':
                continue # Only add one direction
            g.connect(stops[stop][4], stops[connection][4], connections[stop][connection][0].seconds/60, connections[stop][connection][1], 'ba')


    return g
