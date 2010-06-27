
namespace Gpx {

	public class Parser : Object {
		public Root root { get; set; }
		
		public Root? parse_file (string filename) {
			Xml.Doc* xml = Xml.Parser.parse_file (filename);
			if (xml != null) {
				Xml.Node* root_node = xml->get_root_element ();
				return parse_root (root_node);
			}
			return null;
		}

		public void parse_data (string data) {
			Xml.Doc* xml = Xml.Parser.parse_memory (data, (int) data.length);
			if (xml != null) {
				Xml.Node* root_node = xml->get_root_element ();
				root = parse_root (root_node);
			}
		}

		Root parse_root (Xml.Node* node) {
			var root = new Root();
			
			Xml.Node* sub_node = node->children;

			while (sub_node != null) {
				switch (sub_node->name) {
					case "name":
						root.name = sub_node->get_content();
						break;
					case "desc": 
						root.description = sub_node->get_content(); 
						break;
					case "author": 
						root.author = sub_node->get_content(); 
						break;
					case "time": 
						root.time = sub_node->get_content(); 
						break;
					case "keywords": 
						root.keywords = sub_node->get_content(); 
						break;
					case "bounds": 
						root.bounds = sub_node->get_content(); 
						break;
					case "trk": 
						var track = parse_track (sub_node); 
						root.add_track (track);
						break;
					case "wpt": 
						var waypoint = parse_waypoint (sub_node);
						root.add_waypoint (waypoint);
						break;
				} 
				sub_node = sub_node->next;
			}
			return root;
		}
		
		Track parse_track (Xml.Node* node) {
			var sub_node = node->children;
			var track = new Track();
			while (sub_node != null) {
				switch (sub_node->name) {
					case "name":
						track.name = sub_node->get_content();
						break;
					case "desc": 
						track.description = sub_node->get_content(); 
						break;
					case "cmt": 
						track.comment = sub_node->get_content(); 
						break;
					case "src": 
						track.source = sub_node->get_content(); 
						break;
					case "number": 
						track.number = sub_node->get_content().to_int64 (); 
						break;
					case "trkseg": 
						track.add_segment (parse_segment (sub_node));
						break;
					case "wpt": 
						var waypoint = parse_waypoint (sub_node);
						root.add_waypoint (waypoint);
						break;
				}
				sub_node = sub_node->next;
			}
			return track;
		}
		
		TrackSegment parse_segment (Xml.Node* node) {
			var sub_node = node->children;
			var segment = new TrackSegment();
			while (sub_node != null) {
				switch (sub_node->name) {
					case "trkpt":
						segment.add_point (parse_waypoint (sub_node));
						break;
				}
				sub_node = sub_node->next;
			}
			return segment;
		}
		
		Waypoint parse_waypoint (Xml.Node* node) {
			var waypoint = new Waypoint();
			waypoint.latitude = node->get_prop("lat").to_double ();
			waypoint.longitude = node->get_prop("lon").to_double ();
			
			var sub_node = node->children;
			while (sub_node != null) {
				switch (sub_node->name) {
				case "ele":
					waypoint.elevation = sub_node->get_content ().to_int ();
					break;
				case "time":
					waypoint.time = sub_node->get_content ();
					break;
				case "name":
					waypoint.name = sub_node->get_content ();
					break;
				case "desc":
					waypoint.description = sub_node->get_content ();
					break;
				case "src":
					waypoint.source = sub_node->get_content ();
					break;
				case "link":
					waypoint.link = sub_node->get_content ();
					break;
				case "type":
					waypoint.waypoint_type = sub_node->get_content( );
					break;
				case "sat":
					waypoint.number_of_satellites = sub_node->get_content ().to_int ();
					break;
				}
				sub_node = sub_node->next;
			}
			
			return waypoint;
		}
	}
}
