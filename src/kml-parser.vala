namespace Kml {

	public class Parser : Object {

		public Root parse_file (string filename) {
			var parser = new XmlParser();
			var element = parser.parse_file (filename);
			return parse_root (element);
		}

		public Root parse_data (string data) {
			var parser = new XmlParser();
			var element = parser.parse_data (data);
			return parse_root (element);
		}

		void parse_object (XmlElement element, Kml.Object object) {
			string? id = element["id"];
			if (id != null) {
				object.id = id;
			}
			string? target_id = element["targetId"];
			if (target_id != null) {
				object.target_id = target_id;
			}
		}

		Root parse_root (XmlElement element) {
			var root = new Root();
			foreach (XmlElement sub_element in element) {
				parse_root_element (sub_element, root);
			}
			return root;
		}

		Document parse_document (XmlElement element) {
			var document = new Document ();
			parse_object (element, document);

			foreach (XmlElement sub_element in element) {
				parse_container_elements (sub_element, document);
			}
			return document;
		}

		Folder parse_folder (XmlElement element) {
			var folder = new Folder ();
			parse_object (element, folder);

			foreach (XmlElement sub_element in element) {
				parse_container_elements (sub_element, folder);
			}
			return folder;
		}

		NetworkLink parse_network_link (XmlElement element) {
			var network_link = new NetworkLink();
			parse_object (element, network_link);

			foreach (XmlElement sub_element in element) {
				parse_feature_elements (sub_element, network_link);
				parse_network_link_elements (sub_element, network_link);
			}
			return network_link;
		}

		void parse_root_element (XmlElement element, Root root) {
			switch (element.name) {
				case "Document":
					var document = parse_document (element);
					root.add_feature (document);
					break;
				case "Placemark":
					var placemark = parse_placemark (element);
					root.add_feature (placemark);
					break;
				case "Folder":
					var folder = parse_folder (element);
					root.add_feature (folder);
					break;
				case "NetworkLink":
					var network_link = parse_network_link (element);
					root.add_feature (network_link);
					break;
			}
		}

		void parse_feature_elements (XmlElement element, Feature feature) {
			switch (element.name) {
				case "name":
					feature.name = element.get_content().strip();
					break;
				case "visibility":
					feature.visibility = element.get_content().strip() == "1";
					break;
				case "open":
					feature.open = element.get_content().strip() == "1";
					break;
				case "description":
					feature.description = element.get_content().strip();
					break;
				case "address":
					feature.address = element.get_content().strip();
					break;
				case "TimeSpan":
					feature.time = parse_time_span (element);
					break;
				case "TimeStamp":
					feature.time = parse_time_stamp (element);
					break;
				case "styleUrl":
					feature.style_url = element.get_content().strip();
					break;
				case "Snippet":
					feature.snippet = parse_snippet (element);
					break;
				case "Style":
					feature.add_style_selector (parse_style (element));
					break;
				case "StyleMap":
					feature.add_style_selector (parse_style_map (element));
					break;
			}
		}

		void parse_container_elements (XmlElement element, Container container) {
			parse_feature_elements (element, container);
			switch (element.name) {
				case "Placemark":
					var placemark = parse_placemark (element);
					container.add_feature (placemark);
					break;
				case "NetworkLink":
					var network_link = parse_network_link (element);
					container.add_feature (network_link);
					break;
				case "Document":
					var sub_document = parse_document (element);
					container.add_feature (sub_document);
					break;
				case "Folder":
					var sub_folder = parse_folder (element);
					container.add_feature (sub_folder);
					break;
			}
		}

		void parse_network_link_elements (XmlElement element, NetworkLink network_link) {
			switch (element.name) {
				case "Link":
					network_link.link = parse_link (element);
					break;
				case "Url": // from old KML specs
					network_link.link = parse_link (element);
					break;
			}
		}

		void parse_abstract_link_elements (XmlElement element, AbstractLink abstract_link) {
			switch (element.name) {
				case "href":
					abstract_link.href = element.get_content ().strip ();
					break;
				case "refreshMode":
					abstract_link.refresh_mode = element.get_content ().strip ();
					break;
				case "refreshInterval":
					abstract_link.refresh_interval = element.get_double_content ();
					break;
				case "viewRefreshMode":
					abstract_link.view_refresh_mode = element.get_content ().strip ();
					break;
				case "viewRefreshTime":
					abstract_link.view_refresh_time = element.get_double_content ();
					break;
				case "viewFormat":
					abstract_link.view_format = element.get_content ().strip ();
					break;
				case "viewBoundScale":
					abstract_link.view_bound_scale = element.get_double_content ();
					break;
			}
		}

		Link parse_link (XmlElement element) {
			var link = new Link();
			parse_object (element, link);

			foreach (XmlElement sub_element in element) {
				parse_abstract_link_elements (sub_element, link);
			}
			return link;
		}

		Icon parse_icon (XmlElement element) {
			var icon = new Icon();
			parse_object (element, icon);

			foreach (XmlElement sub_element in element) {
				parse_abstract_link_elements (sub_element, icon);
			}
			return icon;
		}

		void parse_placemark_elements (XmlElement element, Placemark placemark) {
			switch (element.name) {
				case "Point":
					placemark.geometry = parse_point (element);
					break;
				case "LineString":
					placemark.geometry = parse_line_string (element);
					break;
				case "Polygon":
					placemark.geometry = parse_polygon (element);
					break;
				case "LinearRing":
					placemark.geometry = parse_linear_ring (element);
					break;
				case "MultiGeometry":
					placemark.geometry = parse_multi_geometry (element);
					break;
			}
		}

		Placemark parse_placemark (XmlElement element) {
			var placemark = new Placemark();
			parse_object (element, placemark);

			foreach (XmlElement sub_element in element) {
				parse_feature_elements (sub_element, placemark);
				parse_placemark_elements (sub_element, placemark);
			}
			return placemark;
		}

		void parse_multi_geometry_elements (XmlElement element, MultiGeometry multi_geometry) {
			switch (element.name) {
				case "Point":
					var geometry = parse_point (element);
					multi_geometry.add_geometry (geometry);
					break;
				case "LineString":
					var geometry = parse_line_string (element);
					multi_geometry.add_geometry (geometry);
					break;
				case "Polygon":
					var geometry = parse_polygon (element);
					multi_geometry.add_geometry (geometry);
					break;
				case "LinearRing":
					var geometry = parse_linear_ring (element);
					multi_geometry.add_geometry (geometry);
					break;
				case "MultiGeometry":
					var geometry = parse_multi_geometry (element);
					multi_geometry.add_geometry (geometry);
					break;
			}
		}

		MultiGeometry parse_multi_geometry (XmlElement element) {
			var multi_geometry = new MultiGeometry();
			parse_object (element, multi_geometry);

			foreach (XmlElement sub_element in element) {
				parse_multi_geometry_elements (sub_element, multi_geometry);
			}
			return multi_geometry;
		}

		Point parse_point (XmlElement element) {
			var point = new Point();
			parse_object (element, point);

			foreach (XmlElement sub_element in element) {
				switch (sub_element.name) {
					case "coordinates":
						point.coordinates = parse_coordinates (sub_element);
						break;
				}
			}
			return point;
		}

		void parse_line_string_elements (XmlElement element, LineString line_string) {
			switch (element.name) {
				case "extrude":
					line_string.extrude = element.get_content () == "1";
					break;
				case "tessellate":
					line_string.tessellate = element.get_content () == "1";
					break;
				case "altitudeMode":
					line_string.altitude_mode = element.get_content ();
					break;
				case "coordinates":
					line_string.coordinates = parse_coordinates (element);
					break;
			}
		}

		LineString parse_line_string (XmlElement element) {
			var line_string = new LineString();
			parse_object (element, line_string);

			foreach (XmlElement sub_element in element) {
				parse_line_string_elements (sub_element, line_string);
			}
			return line_string;
		}

		void parse_linear_ring_elements (XmlElement element, LinearRing linear_ring) {
			switch (element.name) {
				case "extrude":
					linear_ring.extrude = element.get_content () == "1";
					break;
				case "tessellate":
					linear_ring.tessellate = element.get_content () == "1";
					break;
				case "altitudeMode":
					linear_ring.altitude_mode = element.get_content ();
					break;
				case "coordinates":
					linear_ring.coordinates = parse_coordinates (element);
					break;
			}
		}

		LinearRing parse_linear_ring (XmlElement element) {
			var linear_ring = new LinearRing();
			parse_object (element, linear_ring);

			foreach (XmlElement sub_element in element) {
				parse_linear_ring_elements (sub_element, linear_ring);
			}
			return linear_ring;
		}

		void parse_polygon_elements (XmlElement element, Polygon polygon) {
			switch (element.name) {
				case "extrude":
					polygon.extrude = element.get_content () == "1";
					break;
				case "tessellate":
					polygon.tessellate = element.get_content () == "1";
					break;
				case "altitudeMode":
					polygon.altitude_mode = element.get_content ();
					break;
				case "outerBoundaryIs":
					polygon.outer_boundary = parse_boundary (element);
					break;
				case "innerBoundaryIs":
					var inner_boundary = parse_boundary (element);
					polygon.add_inner_boundary (inner_boundary);
					break;
			}
		}

		Polygon parse_polygon (XmlElement element) {
			var polygon = new Polygon();
			parse_object (element, polygon);

			foreach (XmlElement sub_element in element) {
				parse_polygon_elements (sub_element, polygon);
			}
			return polygon;
		}

		LinearRing? parse_boundary (XmlElement element) {
			foreach (XmlElement sub_element in element) {
				switch (sub_element.name) {
					case "LinearRing":
						return parse_linear_ring (sub_element);
				}
			}
			return null;
		}

		Coordinates parse_coordinates (XmlElement element) {
			var coordinates = new Coordinates();
			var coordinates_string = element.get_content ();
			var reg = new Regex ("[\n\t ]+");
			string[] coordinates_array = reg.split (coordinates_string.strip());
			foreach (string coordinate_string in coordinates_array) {
				var coordinate = new Coordinate ();
				string[] coordinate_tuples = coordinate_string.split(",");
				coordinate.longitude = coordinate_tuples[0].to_double();
				coordinate.latitude = coordinate_tuples[1].to_double();
				if (coordinate_tuples.length == 3) {
					coordinate.altitude = coordinate_tuples[2].to_double();
				}
				coordinates.add_coordinate (coordinate);
			}
			return coordinates;
		}

		TimeSpan parse_time_span (XmlElement element) {
			var time_span = new TimeSpan();
			parse_object (element, time_span);

			foreach (XmlElement sub_element in element) {
				parse_time_span_elements (sub_element, time_span);
			}
			return time_span;
		}

		TimeStamp parse_time_stamp (XmlElement element) {
			var time_stamp = new TimeStamp();
			parse_object (element, time_stamp);

			foreach (XmlElement sub_element in element) {
				parse_time_stamp_elements (sub_element, time_stamp);
			}
			return time_stamp;
		}

		void parse_time_span_elements (XmlElement element, TimeSpan time_span) {
			switch (element.name) {
				case "begin":
					time_span.begin = element.get_content ().strip ();
					break;
				case "end":
					time_span.end = element.get_content ().strip ();
					break;
			}
		}

		void parse_time_stamp_elements (XmlElement element, TimeStamp time_stamp) {
			switch (element.name) {
				case "when":
					time_stamp.when = element.get_content ().strip ();
					break;
			}
		}

		Snippet parse_snippet (XmlElement element) {
			var snippet = new Snippet ();

			var content = element.get_content ();
			if (content != null) {
				snippet.content = content.strip ();
			}
			var maxLines = element["maxLines"];
			if (maxLines != null) {
				snippet.max_lines = maxLines.to_int ();
			}

			return snippet;
		}

		StyleMap parse_style_map (XmlElement element) {
			var style_map = new StyleMap ();
			parse_object (element, style_map);

			foreach (XmlElement sub_element in element) {
				parse_style_map_elements (sub_element, style_map);
			}
			return style_map;
		}

		void parse_style_map_elements (XmlElement element, StyleMap style_map) {
			switch (element.name) {
				case "Pair":
					var pair = parse_pair (element);
					style_map.add_pair (pair);
					break;
			}
		}

		Pair parse_pair (XmlElement element) {
			var pair = new Pair();
			parse_object (element, pair);

			foreach (XmlElement sub_element in element) {
				parse_pair_elements (sub_element, pair);
			}
			return pair;
		}

		void parse_pair_elements (XmlElement element, Pair pair) {
			switch (element.name) {
				case "key":
					pair.key = element.get_content ().strip ();
					break;
				case "styleUrl":
					pair.style_url = element.get_content ().strip ();
					break;
				case "Style":
					pair.style = parse_style (element);
					break;
			}
		}

		Style parse_style (XmlElement element) {
			var style = new Style ();
			parse_object (element, style);

			foreach (XmlElement sub_element in element) {
				parse_style_elements (sub_element, style);
			}
			return style;
		}

		void parse_style_elements (XmlElement element, Style style) {
			switch (element.name) {
				case "IconStyle":
					style.icon_style = parse_icon_style (element);
					break;
				case "LabelStyle":
					style.label_style = parse_label_style (element);
					break;
				case "LineStyle":
					style.line_style = parse_line_style (element);
					break;
				case "PolyStyle":
					style.poly_style = parse_poly_style (element);
					break;
				case "BalloonStyle":
					style.balloon_style = parse_balloon_style (element);
					break;
				case "ListStyle":
					style.list_style = parse_list_style (element);
					break;
			}
		}

		void parse_color_style_elements (XmlElement element, ColorStyle color_style) {
			switch (element.name) {
				case "color":
					color_style.color = element.get_content ().strip ();
					break;
				case "colorMode":
					color_style.color_mode = element.get_content ().strip ();
					break;
			}
		}

		IconStyle parse_icon_style (XmlElement element) {
			var icon_style = new IconStyle ();
			parse_object (element, icon_style);

			foreach (XmlElement sub_element in element) {
				parse_color_style_elements (sub_element, icon_style);
				parse_icon_style_elements (sub_element, icon_style);
			}
			return icon_style;
		}

		void parse_icon_style_elements (XmlElement element, IconStyle icon_style) {
			switch (element.name) {
				case "scale":
					icon_style.scale = element.get_double_content ();
					break;
				case "heading":
					icon_style.heading = element.get_double_content ();
					break;
				case "Icon":
					icon_style.icon = parse_icon (element);
					break;
			}
		}

		LabelStyle parse_label_style (XmlElement element) {
			var label_style = new LabelStyle ();
			parse_object (element, label_style);

			foreach (XmlElement sub_element in element) {
				parse_color_style_elements (sub_element, label_style);
				parse_label_style_elements (sub_element, label_style);
			}
			return label_style;
		}

		void parse_label_style_elements (XmlElement element, LabelStyle label_style) {
			switch (element.name) {
				case "scale":
					label_style.scale = element.get_double_content ();
					break;
			}
		}

		LineStyle parse_line_style (XmlElement element) {
			var line_style = new LineStyle ();
			parse_object (element, line_style);

			foreach (XmlElement sub_element in element) {
				parse_color_style_elements (sub_element, line_style);
				parse_line_style_elements (sub_element, line_style);
			}
			return line_style;
		}

		void parse_line_style_elements (XmlElement element, LineStyle line_style) {
			switch (element.name) {
				case "width":
					line_style.width = element.get_double_content ();
					break;
			}
		}

		PolyStyle parse_poly_style (XmlElement element) {
			var poly_style = new PolyStyle ();
			parse_object (element, poly_style);

			foreach (XmlElement sub_element in element) {
				parse_color_style_elements (sub_element, poly_style);
				parse_poly_style_elements (sub_element, poly_style);
			}
			return poly_style;
		}

		void parse_poly_style_elements (XmlElement element, PolyStyle poly_style) {
			switch (element.name) {
				case "fill":
					poly_style.fill = element.get_bool_content ();
					break;
				case "outline":
					poly_style.outline = element.get_bool_content ();
					break;
			}
		}

		BalloonStyle parse_balloon_style (XmlElement element) {
			var balloon_style = new BalloonStyle ();
			parse_object (element, balloon_style);

			foreach (XmlElement sub_element in element) {
			}

			return balloon_style;
		}

		ListStyle parse_list_style (XmlElement element) {
			var list_style = new ListStyle ();
			parse_object (element, list_style);

			foreach (XmlElement sub_element in element) {
			}

			return list_style;
		}
	}

}
