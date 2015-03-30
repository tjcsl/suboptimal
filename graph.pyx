from uuid import uuid4
from libc.math cimport sin,cos,acos,fabs

class PathDoesNotExistException(Exception):
	pass

cdef class Vertex:
	def add_path(self, path):
		self.paths[path.destination] = path

	def __cinit__(self, long id, str name, double latitude, double longitude, set lines):
		self.name = name
		self.paths = {}
		self.id = id
		self.latitude = latitude
		self.longitude = longitude
		self.lines = lines

	def __hash__(Vertex self):
		return self.id

	def __repr__(Vertex self):
		return self.name

	def __richcmp__(Vertex v1, Vertex v2, int op):
		if op == 2:
			return hash(v1) == hash(v2)

		raise NotImplementedError("Vertex __richcmp__ opcode %d" % op)

cdef class Path:
	def __cinit__(self, Vertex source, Vertex destination, double distance, set lines):
		self.destination = destination
		self.distance = distance
		self.source = source
		self.lines = lines

cdef class Graph:
	def add_vertex(self, name="N/A", latitude=0.0, longitude=0.0, lines={"N/A"}):
		new_lines = set()
		for line in list(lines):
			new_lines.add(line+'_A')
			new_lines.add(line+'_B')
		v = Vertex(self.max_id, name, latitude, longitude, new_lines)
		self.max_id += 1
		self.vertices.append(v)
		return v

	def connect(self, v1, v2, distance, lines, direction='ba'):
		new_line1 = set()
		new_line2 = set()
		if direction == 'ba':
			first_direction = '_A'
			second_direction = '_B'
		else:
			first_direction = '_B'
			second_direction = '_A'

		for line in list(lines):
			new_line1.add(line+first_direction)
			new_line2.add(line+second_direction)

		path1 = Path(v1, v2, distance, new_line1)
		path2 = Path(v2, v1, distance, new_line2)
		v1.add_path(path1)
		v2.add_path(path2)

	def get_vertex_by_name(self, name):
		for vertex in self.vertices:
			if vertex.name == name:
				return vertex

		return None

	cdef list neighbors(Graph self, Vertex v):
		return [p.destination for p in v.paths.values()]

	cdef list hubs(Graph self, int n = 3):
		return sorted(self.vertices, key=lambda v:len(v.paths))[:n]

	cpdef double sph_distance(Graph self, Vertex v1, Vertex v2):
		return 6371.0 * acos(sin(v1.latitude)*sin(v2.latitude) + cos(v1.latitude)*cos(v2.latitude)*cos(fabs(v1.longitude-v2.longitude))) # Great-circle distance

	cpdef double distance(Graph self, Vertex v1, Vertex v2):
		if v2 not in v1.paths:
			raise PathDoesNotExistException("%s -> %s" % (v1.name,v2.name))

		return v1.paths[v2].distance

	cpdef list leaf_vertices(Graph self):
		cdef Vertex v
		return [v for v in self.vertices if len(v.paths) <= 1]

	def __cinit__(self):
		self.vertices = []
		self.max_id = 0