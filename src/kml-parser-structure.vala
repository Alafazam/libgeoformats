/* kml-parser-structure.vala
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

namespace Kml {

	public class Object : GLib.Object {
		public string id { get; set; }
		public string target_id { get; set; }
	}

	public class Root : GLib.Object {
		public unowned List<Feature> features { get; set; }

		public void add_feature (Feature feature) {
			features.append (feature);
		}
	}

	public class Coordinate : GLib.Object {
		public double latitude { get; set; }
		public double longitude { get; set; }
		public double altitude { get; set; }
	}

	public class Coordinates : GLib.Object {
		public unowned List<Coordinate> list { get; set; }
		public void add_coordinate (Coordinate coordinate) {
			list.append (coordinate);
		}
	}

	public class Snippet : GLib.Object {
		public string content { get; set; }
		public int max_lines { get; set; }
	}

	/* Geometry and friends*/
	public abstract class Geometry : Kml.Object {
	}

	public class Point : Geometry {
		public bool extrude { get; set; }
		public string altitude_mode { get; set; }
		public Coordinates coordinates { get; set; }
	}

	public class LineString : Geometry {
		public bool extrude { get; set; }
		public bool tessellate { get; set; }
		public string altitude_mode { get; set; }
		public Coordinates coordinates { get; set; }
	}

	public class LinearRing : Geometry {
		public bool extrude { get; set; }
		public bool tessellate { get; set; }
		public string altitude_mode { get; set; }
		public Coordinates coordinates { get; set; }
	}

	public class Polygon : Geometry {
		public bool extrude { get; set; }
		public bool tessellate { get; set; }
		public string altitude_mode { get; set; }
		public LinearRing outer_boundary { get; set; }
		public unowned List<LinearRing> inner_boundaries { get; set; }

		public void add_inner_boundary (LinearRing inner_boundary) {
			inner_boundaries.append (inner_boundary);
		}
	}

	public class MultiGeometry : Geometry {
		public unowned List<Geometry> geometries { get; set; }

		public void add_geometry (Geometry geometry) {
			geometries.append (geometry);
		}
	}

	/* Feature and friends*/
	public class Feature : Kml.Object {
		public string name { get; set; }
		public bool visibility { get; set; }
		public bool open { get; set; }
		public Snippet snippet { get; set; }
		public string description { get; set; }
		public string address { get; set; }
		public TimePrimitive time { get; set; }
		public string style_url { get; set; }

		public unowned List<StyleSelector> style_selectors { get; set; }

		public void add_style_selector(StyleSelector style_selector) {
			style_selectors.append (style_selector);
		}
	}

	public class Placemark : Feature {
		public Geometry geometry { get; set; }
	}

	public class NetworkLink : Feature {
		public Link link { get; set; }
	}

	public class Container : Feature {
		public unowned List<Feature> features { get; set; }

		public void add_feature (Feature feature) {
			features.append (feature);
		}
	}

	public class Folder : Container {
	}

	public class Document : Container {
	}

	/* Link and Icon and friends*/
	public class AbstractLink : Object {
		public string href { get; set; }
		//refresh_mode values: onChange, onInterval, onExpire
		public string refresh_mode { get; set; }
		public double refresh_interval  { get; set; }
		//view_refresh_mode values: never, onStop, onRequest, onRegion
		public string view_refresh_mode  { get; set; }
		public double view_refresh_time  { get; set; }
		public double view_bound_scale  { get; set; }
		public string view_format  { get; set; }
		public string http_query  { get; set; }
	}

	public class Link : AbstractLink {
	}

	public class Icon : AbstractLink {
	}

	/* Style Selector and friends*/

	public class Pair : Object {
		public string key { get; set; }
		public string? style_url { get; set; }
		public Style? style { get; set; }
	}

	public abstract class StyleSelector : Kml.Object {
	}

	public class StyleMap : StyleSelector {
		public unowned List<Pair> pairs { get; set; }

		public void add_pair (Pair pair) {
			pairs.append (pair);
		}
	}

	public class Style : StyleSelector {
		public IconStyle icon_style { get; set; }
		public LabelStyle label_style { get; set; }
		public LineStyle line_style { get; set; }
		public PolyStyle poly_style { get; set; }
		public ListStyle list_style { get; set; }
		public BalloonStyle balloon_style { get; set; }
	}

	/* Sub Style and friends*/
	public abstract class SubStyle : Kml.Object {
	}

	public class BalloonStyle : SubStyle {
	}

	public class ListStyle : SubStyle {
	}

	public class ColorStyle : SubStyle {
		public string color { get; set; }
		public string color_mode { get; set; }
	}

	public class LineStyle : ColorStyle {
		public double width { get; set; }
	}

	public class PolyStyle : ColorStyle {
		public bool fill { get; set; }
		public bool outline { get; set; }
	}

	public class IconStyle : ColorStyle {
		public double scale { get; set; }
		public double heading { get; set; }
		public Icon icon { get; set; }
  	}

	public class LabelStyle : ColorStyle {
		public double scale { get; set; }
	}

	/* Time Primitive and friends*/
	public abstract class TimePrimitive : Kml.Object {
	}

	public  class TimeSpan : TimePrimitive {
		public string begin { get; set; }
		public string end { get; set; }
	}

	public class TimeStamp : TimePrimitive {
		public string when { get; set; }
	}

	/* Abstract View and friends*/
	public abstract class AbstractView : Kml.Object {
		public TimePrimitive time { get; set; }
	}

	public class Camera : AbstractView {
		public double longitude { get; set; }
		public double latitude { get; set; }
		public double altitude { get; set; }
		public double heading { get; set; }
		public double tilt { get; set; }
		public double roll { get; set; }
		public string altitude_mode { get; set; }
	}

	public class LookAt : AbstractView {
		public double longitude { get; set; }
		public double latitude { get; set; }
		public double altitude { get; set; }
		public double heading { get; set; }
		public double tilt { get; set; }
		public double range { get; set; }
		public string altitude_mode { get; set; }
	}
}
