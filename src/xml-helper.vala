namespace XmlHelp {

	public class SearchResult {
		Xml.XPath.Object* object;
		int current = 0;
		public int size { get; private set; }

		public SearchResult (Xml.XPath.Object* object) {
			this.object =object;
			size = object->nodesetval->length ();
		}

		public Element? next_value () {
			if (current >= size) {
				return null;
			}
			var node = object->nodesetval->item (current);
			current++;
			return new Element (node);
		}

		public SearchResult iterator () {
			return this;
		}
	}

	public class Document {
		Xml.Doc* xml;

		public Element get_root () {
			return new Element(xml->get_root_element ());
		}

		public Element parse_file (string filename) {
			xml = Xml.Parser.parse_file (filename);
			return new Element(xml->get_root_element ());
		}

		public Element parse_data (string data) {
			xml = Xml.Parser.parse_memory (data, (int) data.length);
			return new Element (xml->get_root_element ());
		}

		public SearchResult search (string expression) {
			if (xml == null) {
				return new SearchResult (null);
			}
			var context = new Xml.XPath.Context (xml);
			var object = context.eval (expression);
			return new SearchResult (object);
		}
	}

	public class ElementIterator {

		Xml.Node* node;
		ElementType element_type;

		public ElementIterator (Xml.Node* node, ElementType element_type = ElementType.ANY) {
			this.node = node;
			this.element_type = element_type;
		}

		private bool should_skip_node (Xml.Node* node) {
			if (node == null || element_type == ElementType.ANY) {
				return false;
			}

			switch (node->type) {
				case Xml.ElementType.ELEMENT_NODE:
					return element_type != ElementType.ELEMENT;
				case Xml.ElementType.ATTRIBUTE_NODE:
					return element_type != ElementType.ATTRIBUTE;
				case Xml.ElementType.TEXT_NODE:
					return element_type != ElementType.TEXT;
				case Xml.ElementType.COMMENT_NODE:
					return element_type != ElementType.COMMENT;
			}
			return true;
		}

		public Element? next_value () {
			while (should_skip_node (node)) {
				node = node->next;
			}

			if (node == null) {
				return null;
			}

			var element = new Element (node);
			node = node->next;
			return element;
		}

		public ElementIterator iterator () {
			return this;
		}
	}

	public class Element {
		Xml.Node* current_node;

		public string name {
			get { return current_node->name; }
		}

		public Element (Xml.Node* current_node) {
			this.current_node = current_node;
		}

		public ElementIterator iterator () {
			return new ElementIterator (current_node->children);
		}

		public ElementIterator sub_elements (ElementType type) {
			return new ElementIterator (current_node->children, type);
		}

		public string get_content () {
			return current_node->get_content ();
		}

		public double get_double_content () {
			return get_content ().to_double ();
		}

		public bool get_bool_content () {
			return get_content ().to_bool ();
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

	public enum ElementType {
		ANY,
		ELEMENT,
		ATTRIBUTE,
		TEXT,
		COMMENT,
	}
}
