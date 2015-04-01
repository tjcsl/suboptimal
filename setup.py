from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize

ext_modules = [
	Extension("tsp",
		sources = ["tsp.pyx"],
		libraries = ["m"]),
	Extension("graph",
		sources = ["graph.pyx"],
		libraries = ["m"]),
	Extension("gtfs",
		sources = ["gtfs.pyx"])
]

setup(
        name = 'suboptimal',
        ext_modules = cythonize(ext_modules),
)
