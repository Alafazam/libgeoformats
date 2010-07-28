using Kml;

public class TestKmlParser : GLib.Object {

	public static void test_parse_description_text () {
		var parser = new Parser ();
		Root root = parser.parse_file ("kml_test_documents/feature_description.kml");

		Document document;

		document = root.features.nth_data(0) as Document;
		assert (document.name == "My Document 1");
		assert (document.description == "Quoted \"simple\"");

		document = root.features.nth_data(1) as Document;
		assert (document.name == "My Document 2");
		assert (document.description == "<html>With C DATA</html>");

	}

	public static void test_parse_common_feature () {
		var parser = new Parser ();
		Root root = parser.parse_file ("kml_test_documents/common_features.kml");

		var document = root.features.nth_data(0) as Document;
		assert (document.name == "My Document");
		assert (document.description == "Collection of places I \"like\"");
		assert (document.address == "Address of Document");
		assert (document.style_url == "#myStyle");
		assert (document.features.length () == 0);
		var time_stamp = document.time as TimeStamp;
		assert (time_stamp.when == "1997-07-16");
		var snippet = document.snippet;
		assert (snippet.max_lines == 4);
	}

	public static void test_parse_document () {
		var parser = new Parser ();
		Root root =  parser.parse_file ("kml_test_documents/simple_document.kml");
		var document = root.features.nth_data(0) as Document;
		assert (document.name == "My Places");
		assert (document.description == "Collection of places I like");
		assert (document.features.length () == 0);
	}

	public static void test_parse_document_with_style () {
		var parser = new Parser ();
		Root root = parser.parse_file ("kml_test_documents/document_with_style.kml");
		var document = root.features.nth_data(0) as Document;
		assert (document.style_selectors.length () == 1L);
		var style = document.style_selectors.nth_data(0) as Style;
		assert (style.id == "myStyle");
		assert (style.icon_style.scale == 1.0);
		assert (style.icon_style.color == "a1ff00ff");
		assert (style.icon_style.icon.href == "http://myserver.com/icon.jpg");

		assert (style.label_style.scale == 1.5);
		assert (style.label_style.color == "7fffaaff");

		assert (style.line_style.width == 15);
		assert (style.line_style.color == "ff0000ff");

		assert (style.poly_style.color == "7f7faaaa");
		assert (style.poly_style.color_mode == "random");
	}

	public static void test_parse_document_with_style_and_style_map () {
		var parser = new Parser ();
		Root root = parser.parse_file ("kml_test_documents/document_with_style_and_style_map.kml");
		var document = root.features.nth_data(0) as Document;
		assert (document.style_selectors.length () == 2L);
		var style = document.style_selectors.nth_data(0)as Style;
		assert (style.id == "myStyle");
		assert (style.icon_style.icon.href == "http://myserver.com/icon.jpg");
		var style_map = document.style_selectors.nth_data(1) as StyleMap;

		var pair_1 = style_map.pairs.nth_data(0);
		assert (pair_1.key == "normal");
		assert (pair_1.style_url == "#myStyle");
		assert (pair_1.style == null);

		var pair_2 = style_map.pairs.nth_data(1);
		assert (pair_2.key == "highlight");
		assert (pair_2.style_url == null);
		assert (pair_2.style.id == "myInnerStyle");
		assert (pair_2.style.icon_style.color == "00FF0000");
	}

	public static void test_parse_folder () {
		var parser = new Parser ();
		Root root = parser.parse_file ("kml_test_documents/nested_folders.kml");
		var folder = root.features.nth_data(0) as Folder;

		assert (folder.name == "My Places");
		assert (folder.description == "Collection of places I like");
		assert (folder.features.length () == 0);

		var sub_folder = folder.features.nth_data(0) as Folder;
		assert (sub_folder.name == "Nested 1");

		var sub_sub_folder = sub_folder.features.nth_data(0) as Folder;
		assert (sub_sub_folder.name == "Nested 2");

	}

	public static void test_parse_placemark_point () {
		var parser = new Parser ();
		Root root = parser.parse_file ("kml_test_documents/simple_placemark_point.kml");
		var document = root.features.nth_data(0) as Document;
		assert (document.name == "Japan");
		assert (document.description == "Placemarks from Japan");

		assert (document.features.length () == 1);

		var placemark = document.features.nth_data(0) as Placemark;
		assert (placemark.name == "Osaka");
		assert (placemark.description == "Osaka eki");
		var point = placemark.geometry as Point;
		assert (point.coordinates.list.length () == 1);
		var coordinate = point.coordinates.list.nth_data(0);

		assert (Math.fabs (coordinate.latitude - 34.704365) < 0.0000001);
		assert (Math.fabs (coordinate.longitude - 135.495071) < 0.0000001);
		assert (Math.fabs (coordinate.altitude - 0.0) < 0.0000001);
	}

	public static void test_parse_placemark_linestring() {
		var parser = new Parser ();
		Root root = parser.parse_file ("kml_test_documents/simple_placemark_linestring.kml");
		var document = root.features.nth_data(0) as Document;
		assert (document.name == "Japan");
		assert (document.description == "Placemarks from Japan");

		assert (document.features.length () == 1);

		var placemark = document.features.nth_data(0) as Placemark;
		assert (placemark.name == "Railway from Nagasaki");
		assert (placemark.description == "Nothing in particular");
		var linestring = placemark.geometry as LineString;
		assert (linestring.coordinates.list.length () == 7);

		Coordinate coordinate;

		coordinate = linestring.coordinates.list.nth_data(0);
		assert (check_epsilon (coordinate.latitude, 32.753441));
		assert (check_epsilon (coordinate.longitude, 129.870071));
		assert (check_epsilon (coordinate.altitude, 0.0));

		coordinate = linestring.coordinates.list.nth_data(1);
		assert (check_epsilon (coordinate.latitude, 32.757191));
		assert (check_epsilon (coordinate.longitude, 129.867661));
		assert (check_epsilon (coordinate.altitude, 0.0));

		coordinate = linestring.coordinates.list.nth_data(2);
		assert (check_epsilon (coordinate.latitude, 32.760288));
		assert (check_epsilon (coordinate.longitude, 129.865173));
		assert (check_epsilon (coordinate.altitude, 0.0));

		coordinate = linestring.coordinates.list.nth_data(3);
		assert (check_epsilon (coordinate.latitude, 32.763039));
		assert (check_epsilon (coordinate.longitude, 129.863724));
		assert (check_epsilon (coordinate.altitude, 0.0));

		coordinate = linestring.coordinates.list.nth_data(4);
		assert (check_epsilon (coordinate.latitude, 32.767872));
		assert (check_epsilon (coordinate.longitude, 129.862854));
		assert (check_epsilon (coordinate.altitude, 0.0));

		coordinate = linestring.coordinates.list.nth_data(5);
		assert (check_epsilon (coordinate.latitude, 32.779129));
		assert (check_epsilon (coordinate.longitude, 129.860977));
		assert (check_epsilon (coordinate.altitude, 0.0));

		coordinate = linestring.coordinates.list.nth_data(6);
		assert (check_epsilon (coordinate.latitude, 32.785118));
		assert (check_epsilon (coordinate.longitude, 129.861237));
		assert (check_epsilon (coordinate.altitude, 0.0));
	}

	public static void test_parse_network_link () {
		var parser = new Parser ();
		Root root = parser.parse_file ("kml_test_documents/simple_network_link.kml");
		var newtwork_link = root.features.nth_data(0) as NetworkLink;
		assert (newtwork_link.name == "Some map");

		var link = newtwork_link.link;

		assert (link.href == "http://www.example.com/MergedReflectivityQComposite.kml");
		assert (link.refresh_mode == "onInterval");
		assert (link.refresh_interval == 30.0);
		assert (link.view_refresh_mode == "onStop");
		assert (link.view_refresh_time == 7.0);
		assert (link.view_format == "BBOX=[bboxWest],[bboxSouth],[bboxEast],[bboxNorth]");
	}

	public static bool check_epsilon(double got, double expected) {
		return Math.fabs (got - expected) < 0.0000001;
	}

	public static void test_parse_polygon () {
		var parser = new Parser ();
		Root root = parser.parse_file ("kml_test_documents/simple_polygon.kml");
		var placemark = root.features.nth_data(0) as Placemark;
		assert (placemark.name == "hollow box");

		var polygon = placemark.geometry as Polygon;
		assert (polygon.extrude == true);
		assert (polygon.altitude_mode == "relativeToGround");

		var outer_boundary = polygon.outer_boundary as LinearRing;
		assert (outer_boundary.coordinates.list.length () == 5);

		var inner_boundary = polygon.inner_boundaries.nth_data(0) as LinearRing;
		assert (inner_boundary.coordinates.list.length () == 5);
	}

	public static void test_parse_advanced_network_link () {
		var parser = new Parser ();
		Root root = parser.parse_file ("kml_test_documents/advanced_network_link_2.kml");
		assert (root.features.length () == 1);
		var folder = root.features.nth_data(0) as Folder;

		assert (folder.features.length () == 3);

		var photos_network_link = folder.features.nth_data (0) as NetworkLink;
		assert (photos_network_link.name == "Photos");
		assert (photos_network_link.open == false);
		assert (photos_network_link.visibility == true);
		assert (photos_network_link.link.href == "http://toolserver.org/~para/GeoCommons/kml.php?f=photos");
		assert (photos_network_link.link.view_refresh_mode == "onStop");
		assert (photos_network_link.link.view_refresh_time == 0.5);
		assert (photos_network_link.link.view_format == "BBOX=[bboxWest],[bboxSouth],[bboxEast],[bboxNorth]&VIEWSIZE=[horizPixels]x[vertPixels]");
		assert (photos_network_link.link.view_bound_scale == 0.9);

		var maps_network_link = folder.features.nth_data (1) as NetworkLink;
		assert (maps_network_link.name == "Maps");
		assert (maps_network_link.open == false);
		assert (maps_network_link.visibility == false);
		assert (maps_network_link.link.href == "http://toolserver.org/~para/GeoCommons/kml.php?f=maps");
		assert (maps_network_link.link.view_refresh_mode == "onStop");
		assert (maps_network_link.link.view_refresh_time == 0.5);
		assert (maps_network_link.link.view_format == "BBOX=[bboxWest],[bboxSouth],[bboxEast],[bboxNorth]&VIEWSIZE=[horizPixels]x[vertPixels]");
		assert (maps_network_link.link.view_bound_scale == 0.9);

		var info_network_link = folder.features.nth_data (2) as NetworkLink;
		assert (info_network_link.name == "Info");
		assert (info_network_link.visibility == true);
		assert (info_network_link.link.href == "http://toolserver.org/~para/GeoCommons/info.php");
		assert (info_network_link.link.refresh_mode == "onInterval");
		assert (info_network_link.link.refresh_interval == 3600);
	}
}
