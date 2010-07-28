
public class XmlParser {
	Xml.Doc* xml;

	public XmlElement parse_file (string filename) {
		xml = Xml.Parser.parse_file (filename);
		return new XmlElement(xml->get_root_element ());
	}

	public XmlElement parse_data (string data) {
		xml = Xml.Parser.parse_memory (data, (int) data.length);
		return new XmlElement (xml->get_root_element ());
	}
}

public class XmlElementIterator {

	Xml.Node* node;

	public XmlElementIterator (Xml.Node* node) {
		this.node = node;
	}

	public XmlElement? next_value () {
		if (node == null) {
			return null;
		}
		var element = new XmlElement (node);
		node = node->next;
		return element;
	}
}

public class XmlElement {
	Xml.Node* current_node;

	public string name {
		get { return current_node->name; }
	}

	public XmlElement (Xml.Node* current_node) {
		this.current_node = current_node;
	}

	public XmlElementIterator iterator () {
		return new XmlElementIterator (current_node->children);
	}

	public string get_content () {
		return current_node->get_content ();
	}

	public double get_double_content () {
		return get_content ().to_double ();
	}

	public int get_int_content () {
		return get_content ().to_int ();
	}

	public int64 get_int64_content () {
		return get_content ().to_int64 ();
	}

	public new string get (string key) {
		return current_node->get_prop(key);
	}

}
