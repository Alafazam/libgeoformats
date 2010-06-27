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
