namespace Gpx {

	public class Parser : Object {

		public Root? parse_file (string filename) {
			var document = new XmlHelp.Document ();
			var element = document.parse_file (filename);
			if (element != null) {
				return parse_root (element);
			}
			return null;
		}

		public Root? parse_data (string data) {
			var document = new XmlHelp.Document ();
			var element = document.parse_data (data);
			if (element != null) {
				return parse_root (element);
			}
			return null;
		}

		Root parse_root (XmlHelp.Element element) {
			var root = new Root ();

			foreach (var sub_element in element) {
				switch (sub_element.name) {
					case "name":
						root.name = sub_element.get_content ();
						break;
					case "desc":
						root.description = sub_element.get_content ();
						break;
					case "author":
						root.author = sub_element.get_content ();
						break;
					case "time":
						root.time = sub_element.get_content ();
						break;
					case "keywords":
						root.keywords = sub_element.get_content ();
						break;
					case "bounds":
						root.bounds = sub_element.get_content ();
						break;
					case "trk":
						var track = parse_track (sub_element);
						root.add_track (track);
						break;
					case "wpt":
						var waypoint = parse_waypoint (sub_element);
						root.add_waypoint (waypoint);
						break;
				}
			}
			return root;
		}

		Track parse_track (XmlHelp.Element element) {
			var track = new Track ();
			foreach (var sub_element in element) {
				switch (sub_element.name) {
					case "name":
						track.name = sub_element.get_content ();
						break;
					case "desc":
						track.description = sub_element.get_content ();
						break;
					case "cmt":
						track.comment = sub_element.get_content ();
						break;
					case "src":
						track.source = sub_element.get_content ();
						break;
					case "number":
						track.number = sub_element.get_int64_content ();
						break;
					case "trkseg":
						track.add_segment (parse_segment (sub_element));
						break;
				}
			}
			return track;
		}

		TrackSegment parse_segment (XmlHelp.Element element) {
			var segment = new TrackSegment ();
			foreach (var sub_element in element) {
				switch (sub_element.name) {
					case "trkpt":
						segment.add_point (parse_waypoint (sub_element));
						break;
				}
			}
			return segment;
		}

		Waypoint parse_waypoint (XmlHelp.Element element) {
			var waypoint = new Waypoint ();
			waypoint.latitude = element["lat"].to_double ();
			waypoint.longitude = element["lon"].to_double ();

			foreach (var sub_element in element) {
				switch (sub_element.name) {
				case "ele":
					waypoint.elevation = sub_element.get_int_content ();
					break;
				case "time":
					waypoint.time = sub_element.get_content ();
					break;
				case "name":
					waypoint.name = sub_element.get_content ();
					break;
				case "desc":
					waypoint.description = sub_element.get_content ();
					break;
				case "src":
					waypoint.source = sub_element.get_content ();
					break;
				case "link":
					waypoint.link = sub_element.get_content ();
					break;
				case "type":
					waypoint.waypoint_type = sub_element.get_content ();
					break;
				case "sat":
					waypoint.number_of_satellites = sub_element.get_int_content ();
					break;
				}
			}

			return waypoint;
		}
	}
}
