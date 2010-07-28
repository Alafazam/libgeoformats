namespace Kml {

	public class Parser : Object {

		public Root parse_file (string filename) {
			Xml.Doc* xml = Xml.Parser.parse_file (filename);
			Xml.Node* root_node = xml->get_root_element ();
			return parse_root (root_node);
		}

		public Root parse_data (string data) {
			Xml.Doc* xml = Xml.Parser.parse_memory (data, (int) data.length);
			Xml.Node* root_node = xml->get_root_element ();
			return parse_root (root_node);
		}

		void parse_object (Xml.Node* node, Kml.Object object) {
			string? id = node->get_prop("id");
			if (id != null) {
				object.id = id;
			}
			string? target_id = node->get_prop("targetId");
			if (target_id != null) {
				object.target_id = target_id;
			}
		}

		Root parse_root (Xml.Node* node) {
			var root = new Root();

			Xml.Node* sub_node = node->children;

			while (sub_node != null) {
				switch (sub_node->name) {
					case "Document":
						var document = parse_document (sub_node);
						root.add_feature (document);
						break;
					case "Placemark":
						var placemark = parse_placemark (sub_node);
						root.add_feature (placemark);
						break;
					case "Folder":
						var folder = parse_folder (sub_node);
						root.add_feature (folder);
						break;
					case "NetworkLink":
						var network_link = parse_network_link (sub_node);
						root.add_feature (network_link);
						break;
				}
				sub_node = sub_node->next;
			}
			return root;
		}

		void parse_feature_elements (Xml.Node* node, Feature feature) {
			switch (node->name) {
				case "name":
					feature.name = node->get_content().strip();
					break;
				case "visibility":
					feature.visibility = node->get_content().strip() == "1";
					break;
				case "open":
					feature.open = node->get_content().strip() == "1";
					break;
				case "description":
					feature.description = node->get_content().strip();
					break;
				case "address":
					feature.address = node->get_content().strip();
					break;
				case "TimeSpan":
					feature.time = parse_time_span (node);
					break;
				case "TimeStamp":
					feature.time = parse_time_stamp (node);
					break;
				case "styleUrl":
					feature.style_url = node->get_content().strip();
					break;
				case "Snippet":
					feature.snippet = parse_snippet (node);
					break;
				case "Style":
					feature.add_style_selector (parse_style (node));
					break;
				case "StyleMap":
					feature.add_style_selector (parse_style_map (node));
					break;
			}
		}

		void parse_container_elements (Xml.Node* node, Container container) {
			parse_feature_elements (node, container);
			switch (node->name) {
				case "Placemark":
					var placemark = parse_placemark (node);
					container.add_feature (placemark);
					break;
				case "NetworkLink":
					var network_link = parse_network_link (node);
					container.add_feature (network_link);
					break;
				case "Document":
					var sub_document = parse_document (node);
					container.add_feature (sub_document);
					break;
				case "Folder":
					var sub_folder = parse_folder (node);
					container.add_feature (sub_folder);
					break;
			}
		}

		Document parse_document (Xml.Node* node) {
			var document = new Document ();
			parse_object (node, document);

			var sub_node = node->children;
			while (sub_node != null) {
				parse_container_elements (sub_node, document);
				sub_node = sub_node->next;
			}
			return document;
		}

		Folder parse_folder (Xml.Node* node) {
			var folder = new Folder ();
			parse_object (node, folder);

			var sub_node = node->children;
			while (sub_node != null) {
				parse_container_elements (sub_node, folder);
				sub_node = sub_node->next;
			}
			return folder;
		}

		public NetworkLink parse_network_link (Xml.Node* node) {
			var network_link = new NetworkLink();
			parse_object (node, network_link);

			var sub_node = node->children;
			while (sub_node != null) {
				parse_feature_elements (sub_node, network_link);
				switch (sub_node->name) {
					case "Link":
						network_link.link = parse_link (sub_node);
						break;
					case "Url": // from old KML specs
						network_link.link = parse_link (sub_node);
						break;
				}
				sub_node = sub_node->next;
			}
			return network_link;
		}

		void parse_abstract_link_elements (Xml.Node* node, AbstractLink abstract_link) {
			switch (node->name) {
				case "href":
					abstract_link.href = node->get_content().strip();
					break;
				case "refreshMode":
					abstract_link.refresh_mode = node->get_content().strip();
					break;
				case "refreshInterval":
					abstract_link.refresh_interval = node->get_content().to_double();
					break;
				case "viewRefreshMode":
					abstract_link.view_refresh_mode = node->get_content().strip();
					break;
				case "viewRefreshTime":
					abstract_link.view_refresh_time = node->get_content().to_double();
					break;
				case "viewFormat":
					abstract_link.view_format = node->get_content().strip();
					break;
				case "viewBoundScale":
					abstract_link.view_bound_scale = node->get_content().to_double();
					break;
			}
		}

		Link parse_link (Xml.Node* node) {
			var link = new Link();
			parse_object (node, link);

			var sub_node = node->children;
			while (sub_node != null) {
				parse_abstract_link_elements (sub_node, link);
				sub_node = sub_node->next;
			}
			return link;
		}

		Icon parse_icon (Xml.Node* node) {
			var icon = new Icon();
			parse_object (node, icon);

			var sub_node = node->children;
			while (sub_node != null) {
				parse_abstract_link_elements (sub_node, icon);
				sub_node = sub_node->next;
			}
			return icon;
		}

		Placemark parse_placemark (Xml.Node* node) {
			var placemark = new Placemark();
			parse_object (node, placemark);

			var sub_node = node->children;
			while (sub_node != null) {
				parse_feature_elements (sub_node, placemark);
				switch (sub_node->name) {
					case "Point":
						placemark.geometry = parse_point (sub_node);
						break;
					case "LineString":
						placemark.geometry = parse_line_string (sub_node);
						break;
					case "Polygon":
						placemark.geometry = parse_polygon (sub_node);
						break;
					case "LinearRing":
						placemark.geometry = parse_linear_ring (sub_node);
						break;
					case "MultiGeometry":
						placemark.geometry = parse_multi_geometry (sub_node);
						break;
				}
				sub_node = sub_node->next;
			}
			return placemark;
		}

		MultiGeometry parse_multi_geometry (Xml.Node* node) {
			var multi_geometry = new MultiGeometry();
			parse_object (node, multi_geometry);

			var sub_node = node->children;
			while (sub_node != null) {
				switch (sub_node->name) {
					case "Point":
						var geometry = parse_point (sub_node);
						multi_geometry.add_geometry (geometry);
						break;
					case "LineString":
						var geometry = parse_line_string (sub_node);
						multi_geometry.add_geometry (geometry);
						break;
					case "Polygon":
						var geometry = parse_polygon (sub_node);
						multi_geometry.add_geometry (geometry);
						break;
					case "LinearRing":
						var geometry = parse_linear_ring (sub_node);
						multi_geometry.add_geometry (geometry);
						break;
					case "MultiGeometry":
						var geometry = parse_multi_geometry (sub_node);
						multi_geometry.add_geometry (geometry);
						break;
				}
				sub_node = sub_node->next;
			}
			return multi_geometry;
		}

		Point parse_point (Xml.Node* node) {
			var point = new Point();
			parse_object (node, point);

			var sub_node = node->children;
			while (sub_node != null) {
				switch (sub_node->name) {
					case "coordinates":
						point.coordinates = parse_coordinates (sub_node);
						break;
				}
				sub_node = sub_node->next;
			}
			return point;
		}

		LineString parse_line_string (Xml.Node* node) {
			var line_string = new LineString();
			parse_object (node, line_string);

			var sub_node = node->children;
			while (sub_node != null) {
				switch (sub_node->name) {
					case "extrude":
						line_string.extrude = sub_node->get_content () == "1";
						break;
					case "tessellate":
						line_string.tessellate = sub_node->get_content () == "1";
						break;
					case "altitudeMode":
						line_string.altitude_mode = sub_node->get_content ();
						break;
					case "coordinates":
						line_string.coordinates = parse_coordinates (sub_node);
						break;
				}
				sub_node = sub_node->next;
			}
			return line_string;
		}

		LinearRing parse_linear_ring (Xml.Node* node) {
			var linear_ring = new LinearRing();
			parse_object (node, linear_ring);

			var sub_node = node->children;
			while (sub_node != null) {
				switch (sub_node->name) {
					case "extrude":
						linear_ring.extrude = sub_node->get_content () == "1";
						break;
					case "tessellate":
						linear_ring.tessellate = sub_node->get_content () == "1";
						break;
					case "altitudeMode":
						linear_ring.altitude_mode = sub_node->get_content ();
						break;
					case "coordinates":
						linear_ring.coordinates = parse_coordinates (sub_node);
						break;
				}
				sub_node = sub_node->next;
			}
			return linear_ring;
		}

		Polygon parse_polygon (Xml.Node* node) {
			var polygon = new Polygon();
			parse_object (node, polygon);

			var sub_node = node->children;
			while (sub_node != null) {
				switch (sub_node->name) {
					case "extrude":
						polygon.extrude = sub_node->get_content () == "1";
						break;
					case "tessellate":
						polygon.tessellate = sub_node->get_content () == "1";
						break;
					case "altitudeMode":
						polygon.altitude_mode = sub_node->get_content ();
						break;
					case "outerBoundaryIs":
						polygon.outer_boundary = parse_boundary (sub_node);
						break;
					case "innerBoundaryIs":
						var inner_boundary = parse_boundary (sub_node);
						polygon.add_inner_boundary (inner_boundary);
						break;
				}
				sub_node = sub_node->next;
			}
			return polygon;
		}

		LinearRing? parse_boundary (Xml.Node* node) {
			var sub_node = node->children;
			while (sub_node != null) {
				switch (sub_node->name) {
					case "LinearRing":
						return parse_linear_ring (sub_node);
				}
				sub_node = sub_node->next;
			}
			return null;
		}

		Coordinates parse_coordinates (Xml.Node* node) {
			var coordinates = new Coordinates();
			var coordinates_string = node->get_content();
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

		TimeSpan parse_time_span (Xml.Node* node) {
			var time_span = new TimeSpan();
			parse_object (node, time_span);

			var sub_node = node->children;
			while (sub_node != null) {
				parse_time_span_elements (sub_node, time_span);
				sub_node = sub_node->next;
			}
			return time_span;
		}

		TimeStamp parse_time_stamp (Xml.Node* node) {
			var time_stamp = new TimeStamp();
			parse_object (node, time_stamp);

			var sub_node = node->children;
			while (sub_node != null) {
				parse_time_stamp_elements (sub_node, time_stamp);
				sub_node = sub_node->next;
			}
			return time_stamp;
		}

		void parse_time_span_elements (Xml.Node* node, TimeSpan time_span) {
			switch (node->name) {
				case "begin":
					time_span.begin = node->get_content().strip();
					break;
				case "end":
					time_span.end = node->get_content().strip();
					break;
			}
		}

		void parse_time_stamp_elements (Xml.Node* node, TimeStamp time_stamp) {
			switch (node->name) {
				case "when":
					time_stamp.when = node->get_content().strip();
					break;
			}
		}

		Snippet parse_snippet (Xml.Node* node) {
			var snippet = new Snippet ();

			var content = node->get_content ();
			if (content != null) {
				snippet.content = content.strip ();
			}
			var maxLines = node->get_prop ("maxLines");
			if (maxLines != null) {
				snippet.max_lines = maxLines.to_int ();
			}

			return snippet;
		}

		StyleMap parse_style_map (Xml.Node* node) {
			var style_map = new StyleMap ();
			parse_object (node, style_map);

			var sub_node = node->children;
			while (sub_node != null) {
				parse_style_map_elements (sub_node, style_map);
				sub_node = sub_node->next;
			}
			return style_map;
		}

		void parse_style_map_elements (Xml.Node* node, StyleMap style_map) {
			switch (node->name) {
				case "Pair":
					var pair  = parse_pair (node);
					style_map.add_pair(pair);
					break;
			}
		}

		Pair parse_pair (Xml.Node* node) {
			var pair = new Pair();
			parse_object (node, pair);

			var sub_node = node->children;
			while (sub_node != null) {
				parse_pair_elements (sub_node, pair);
				sub_node = sub_node->next;
			}
			return pair;
		}

		void parse_pair_elements (Xml.Node* node, Pair pair) {
			switch (node->name) {
				case "key":
					pair.key = node->get_content().strip();
					break;
				case "styleUrl":
					pair.style_url = node->get_content().strip();
					break;
				case "Style":
					pair.style = parse_style (node);
					break;
			}
		}

		Style parse_style (Xml.Node* node) {
			var style = new Style ();
			parse_object (node, style);

			var sub_node = node->children;
			while (sub_node != null) {
				parse_style_elements (sub_node, style);
				sub_node = sub_node->next;
			}
			return style;
		}

		void parse_style_elements (Xml.Node* node, Style style) {
			switch (node->name) {
				case "IconStyle":
					style.icon_style = parse_icon_style (node);
					break;
				case "LabelStyle":
					style.label_style = parse_label_style (node);
					break;
				case "LineStyle":
					style.line_style = parse_line_style (node);
					break;
				case "PolyStyle":
					style.poly_style = parse_poly_style (node);
					break;
				case "BalloonStyle":
					style.balloon_style = parse_balloon_style (node);
					break;
				case "ListStyle":
					style.list_style = parse_list_style (node);
					break;
			}
		}

		void parse_color_style_elements (Xml.Node* node, ColorStyle color_style) {
			switch (node->name) {
				case "color":
					color_style.color = node->get_content().strip();
					break;
				case "colorMode":
					color_style.color_mode = node->get_content().strip();
					break;
			}
		}

		IconStyle parse_icon_style (Xml.Node* node) {
			var icon_style = new IconStyle ();
			parse_object (node, icon_style);

			var sub_node = node->children;
			while (sub_node != null) {
				parse_color_style_elements (sub_node, icon_style);
				parse_icon_style_elements (sub_node, icon_style);
				sub_node = sub_node->next;
			}
			return icon_style;
		}

		void parse_icon_style_elements (Xml.Node* node, IconStyle icon_style) {
			switch (node->name) {
				case "scale":
					icon_style.scale = node->get_content().to_double ();
					break;
				case "heading":
					icon_style.heading = node->get_content().to_double ();
					break;
				case "Icon":
					icon_style.icon = parse_icon (node);
					break;
			}
		}

		LabelStyle parse_label_style (Xml.Node* node) {
			var label_style = new LabelStyle ();
			parse_object (node, label_style);

			var sub_node = node->children;
			while (sub_node != null) {
				parse_color_style_elements (sub_node, label_style);
				parse_label_style_elements (sub_node, label_style);
				sub_node = sub_node->next;
			}
			return label_style;
		}

		void parse_label_style_elements (Xml.Node* node, LabelStyle label_style) {
			switch (node->name) {
				case "scale":
					label_style.scale = node->get_content().to_double ();
					break;
			}
		}

		LineStyle parse_line_style (Xml.Node* node) {
			var line_style = new LineStyle ();
			parse_object (node, line_style);

			var sub_node = node->children;
			while (sub_node != null) {
				parse_color_style_elements (sub_node, line_style);
				parse_line_style_elements (sub_node, line_style);
				sub_node = sub_node->next;
			}
			return line_style;
		}

		void parse_line_style_elements (Xml.Node* node, LineStyle line_style) {
			switch (node->name) {
				case "width":
					line_style.width = node->get_content().to_double ();
					break;
			}
		}

		PolyStyle parse_poly_style (Xml.Node* node) {
			var poly_style = new PolyStyle ();
			parse_object (node, poly_style);

			var sub_node = node->children;
			while (sub_node != null) {
				parse_color_style_elements (sub_node, poly_style);
				parse_poly_style_elements (sub_node, poly_style);
				sub_node = sub_node->next;
			}
			return poly_style;
		}

		void parse_poly_style_elements (Xml.Node* node, PolyStyle poly_style) {
			switch (node->name) {
				case "fill":
					poly_style.fill = node->get_content().to_bool ();
					break;
				case "outline":
					poly_style.outline = node->get_content().to_bool ();
					break;
			}
		}

		BalloonStyle parse_balloon_style (Xml.Node* node) {
			var balloon_style = new BalloonStyle ();
			parse_object (node, balloon_style);

			var sub_node = node->children;
			while (sub_node != null) {
				sub_node = sub_node->next;
			}
			return balloon_style;
		}

		ListStyle parse_list_style (Xml.Node* node) {
			var list_style = new ListStyle ();
			parse_object (node, list_style);

			var sub_node = node->children;
			while (sub_node != null) {
				sub_node = sub_node->next;
			}
			return list_style;
		}
	}

}
