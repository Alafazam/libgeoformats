
public int main (string[] args) {
	Test.init(ref args);

	var test_kml = new TestKmlParser ();
	Test.add_func ("/kml/parse/feature", test_kml.test_parse_common_feature);
	Test.add_func ("/kml/parse/feature/description", test_kml.test_parse_description_text);
	Test.add_func ("/kml/parse/document", test_kml.test_parse_document);
	Test.add_func ("/kml/parse/document/style", test_kml.test_parse_document_with_style);
	Test.add_func ("/kml/parse/document/style_and_style_map", test_kml.test_parse_document_with_style_and_style_map);
	Test.add_func ("/kml/parse/placemark/point", test_kml.test_parse_placemark_point);
	Test.add_func ("/kml/parse/placemark/linestring", test_kml.test_parse_placemark_linestring);
	Test.add_func ("/kml/parse/network_link", test_kml.test_parse_network_link);
	Test.add_func ("/kml/parse/advanced_network_link", test_kml.test_parse_advanced_network_link);
	Test.add_func ("/kml/parse/nested_folders", test_kml.test_parse_placemark_point);
	Test.add_func ("/kml/parse/polygon", test_kml.test_parse_polygon);

	var test_gpx = new TestGpxParser ();
	Test.add_func ("/gpx/parse/test_name_and_description", test_gpx.test_name_and_description);
	Test.add_func ("/gpx/parse/multiple_tracks", test_gpx.test_multiple_tracks);

	Test.run ();

	return 0;
}
