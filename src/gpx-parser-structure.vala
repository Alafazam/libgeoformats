/* gpx-parser-structure.vala
 *
 * Copyright (C) 2010  Tomaž Vajngerl
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.

 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.

 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA
 *
 * Author:
 * 	Tomaž Vajngerl <quikee@gmail.com>
 */

namespace Gpx {
	public class Waypoint : Object {
		public double latitude { get; set; }
		public double longitude { get; set; }
		
		public int elevation { get; set; }
		public string time { get; set; }
		public string name { get; set; }
		public string description { get; set; }
		public string source { get; set; }
		public string link { get; set; }
		public string waypoint_type { get; set; }
		public int number_of_satellites { get; set; }
	}
	
	public class TrackSegment : Object {
		public int number { get; set; }
		public unowned List<Waypoint> points { get; construct; }
		
		construct {
			points = new List<Waypoint>();
		}
		
		public void add_point (Waypoint point) {
			points.append (point);
		}
	}

	public class Track : Object {
		public string name { get; set; }
		public string description { get; set; }
		public int64 number { get; set; }
		public string comment { get; set; }
		public string source { get; set; }
		public unowned List<TrackSegment> segments { get; construct; }
		
		construct {
			segments = new List<TrackSegment>();
		}
		
		public void add_segment (TrackSegment segment) {
			segments.append (segment);
		}
	}
	
	public class Root : Object {
		public string name { get; set; }
		public string description { get; set; }
		public string author { get; set; }
		public string time { get; set; } /* xsd:dateTime */
		public string keywords { get; set; }
		public string bounds { get; set; } /* gpx:boundsType */

		public unowned List<Track> tracks { get; construct; }
		public unowned List<Waypoint> waypoints { get; construct; }
		
		construct {
			tracks = new List<Track> ();
			waypoints = new List<Waypoint> ();
		}
		
		public void add_track (Track track) {
			tracks.append (track);
		}
		public void add_waypoint (Waypoint waypoint) {
			waypoints.append (waypoint);
		}
	}
}
