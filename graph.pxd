cdef class Vertex:
	cdef public str name
	cdef public long id
	cdef public dict paths
	cdef public double latitude
	cdef public double longitude
	cdef public set lines

cdef class Path:
	cdef public double distance
	cdef public Vertex destination
	cdef public Vertex source
	cdef public set lines

cdef class Graph:
	cdef public list vertices
	cdef public long max_id
	cdef list neighbors(Graph, Vertex)
	cdef list hubs(Graph, int n=*)
	cpdef double sph_distance(Graph, Vertex, Vertex)
	cpdef double distance(Graph, Vertex, Vertex)
	cpdef list leaf_vertices(Graph)
