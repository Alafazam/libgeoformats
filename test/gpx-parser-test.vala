using Gpx;

public class TestGpxParser : GLib.Object {
	public static void test_name_and_description () {
		var parser = new Parser ();
		Root root = parser.parse_file ("gpx_test_documents/simple.gpx");

		assert (root.name == "gpx-name");
		assert (root.description == "gpx-description");
		assert (root.author == "gpx-author");
		assert (root.keywords == "gpx-keywords");
		assert (root.bounds == "gpx-bounds");

		Track track = root.tracks.nth_data(0);
		assert (track.name == "track-name");
		assert (track.description == "track-description");
		assert (track.comment == "track-comment");
		assert (track.source == "track-source");
		assert (track.number == 1);
	}

	public static void test_multiple_tracks () {
		var parser = new Parser ();
		Root root = parser.parse_file ("gpx_test_documents/multiple_tracks.gpx");
		Track track = root.tracks.nth_data(0);
		TrackSegment segment = track.segments.nth_data(0);
		assert (segment.points.length () == 6);
	}
}
