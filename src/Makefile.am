NULL =

AM_CPPFLAGS = \
	$(LIBGEOFORMATS_CFLAGS) \
	$(NULL)

BUILT_SOURCES = geoformats.vala.stamp

lib_LTLIBRARIES = \
	libgeoformats.la
	$(NULL)

libgeoformats_la_VALASOURCES = \
	gpx-parser-structure.vala \
	gpx-parser.vala \
	kml-parser-structure.vala \
	kml-parser.vala \
	xml-helper.vala \
	$(NULL)

libgeoformats_la_SOURCES = \
	geoformats.vala.stamp \
	$(libgeoformats_la_VALASOURCES:.vala=.c) \
	$(NULL)

geoformatsincludedir = $(includedir)/geoservices-1.0

geoformatsinclude_HEADERS = \
	geoformats.h \
	$(NULL)

AM_VALAFLAGS = \
	-H geoformats.h \
	--vapi geoformats-1.0.vapi \
	--pkg json-glib-1.0 \
	--pkg libxml-2.0 \
	--library geoformats-1.0 \
	--gir GeoFormats-1.0.gir \
	$(VALAFLAGS) \
	$(NULL)

geoformats-1.0.vapi geoformats.vala.stamp: $(libgeoformats_la_VALASOURCES)
	$(VALAC) -C $(AM_VALAFLAGS) $^
	touch $@

libgeoformats_la_LIBADD = \
	$(LIBGEOSERVICES_LIBS) \
	$(NULL)

libgeoformats_la_LDFLAGS = -version-info $(LIBGEOFORMATS_LT_VERSION)

vapidir = $(datadir)/vala/vapi

dist_vapi_DATA = \
	geoformats-1.0.vapi \
	$(NULL)

girdir = $(datadir)/gir-1.0

dist_gir_DATA = \
	GeoFormats-1.0.gir \
	$(NULL)

CLEANFILES = \
	$(BUILT_SOURCES) \
	$(libgeoformats_la_VALASOURCES:.vala=.c) \
	geoformats-1.0.vapi \
	GeoFormats-1.0.gir \
	geoformats.h

EXTRA_DIST = $(libgeoformats_la_VALASOURCES) geoformats-1.0.vapi GeoFormats-1.0.gir geoservices.vala.stamp
