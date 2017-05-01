from __future__ import division, print_function
import math
import numpy as np
from geometry import Point, intersect

cdef class SegmentHash:
    """docstring for SegmentHash"""
    def __init__(self, width, height, d):
        self.width = width
        self.height = height
        self.d = int(d)

        self.num_x = int(width/self.d)
        self.num_y = int(height/self.d)

        print('Initialized polygrid with', self.num_x, self.num_y, self.d)

        # Each data bucket stores a Vec2D of IDs
        self.data = np.empty((self.num_x, self.num_y), dtype=object)
        for x in range(self.num_x):
            for y in range(self.num_y):
                self.data[x][y] = []

        self.segments = dict() # Map ID -> (p1, p2)

    cdef iterator _segment_supercover(self, int x0, int x1, int y0, int y1):
        """
        Yield all grid positions.
        """
        # Number of squares to cross.
        dx = int(p1.x/self.d) - int(p0.x / self.d)
        dy = int(p1.y/self.d) - int(p0.y / self.d)
        nx = abs(dx)
        ny = abs(dy)

        sign_x = 1 if dx > 0 else -1
        sign_y = 1 if dy > 0 else -1

        px = int(p0.x/self.d)
        py = int(p0.y/self.d)

        ix = 0
        iy = 0

        yield px, py

        while (ix < nx or iy < ny):
            if ny == 0:
                px += sign_x
                ix += 1
            elif nx == 0:
                py += sign_y
                iy += 1
            elif ((0.5+ix) / nx < (0.5+iy) / ny):
                # next step is horizontal
                px += sign_x
                ix += 1
            else:
                # next step is vertical
                py += sign_y
                iy += 1

            yield (px, py)

    def _broad_phase(self, p0, p1):
        for i, j in self._segment_supercover(p0, p1):
            if i > 0 and i < self.num_x and j > 0 and j < self.num_y:
                yield self.data[i, j]

    def in_bounds(self, p):
        if p.x < 0 or p.x >= self.width:
            return False
        if p.y < 0 or p.y >= self.height:
            return False
        return True

    def segment_add(self, id, p0, p1):
        assert(self.in_bounds(p0))
        assert(self.in_bounds(p1))
        assert(id not in self.segments)

        self.segments[id] = (p0, p1)
        for bucket in self._broad_phase(p0, p1):
            bucket.append(id)

    def segment_intersect(self, p0, p1, brute_force=False):
        assert(self.in_bounds(p0))
        assert(self.in_bounds(p1))
        # brute force for testing
        if brute_force:
            for id, (p2, p3) in self.segments.items():
                if intersect(p0, p1, p2, p3):
                    yield id
        else:
            seen = set()
            for bucket in self._broad_phase(p0, p1):
                for id in bucket:
                    if id not in seen:
                        seen.add(id)
                        p2, p3 = self.segments[id]
                        if intersect(p0, p1, p2, p3):
                            yield id

    def segment_remove(self, id):
        assert(id in self.segments)
        p0, p1 = self.segments[id]
        del self.segments[id]
        for bucket in self._broad_phase(p0, p1):
            bucket.remove(id)

    def segment_move(self, id, p0, p1):
        assert(id in self.segments)
        self.segment_remove(id)
        self.segment_add(id, p0, p1)

