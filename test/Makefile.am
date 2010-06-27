NULL =

AM_CPPFLAGS = \
	-I$(top_srcdir)/src \
	$(LIBGEOFORMATS_CFLAGS) \
	$(NULL)

noinst_PROGRAMS = tests

BUILT_SOURCES = tests.vala.stamp

tests_VALASOURCES = \
	testmain.vala \
	gpx-parser-test.vala \
	kml-parser-test.vala \
	$(NULL)

tests_DEPENDENCIES = $(top_srcdir)/src/geoformats-1.0.vapi

tests_SOURCES = tests.vala.stamp $(tests_VALASOURCES:.vala=.c)

tests.vala.stamp: $(tests_VALASOURCES)
	$(VALAC) -C --basedir $(top_srcdir) --vapidir $(top_srcdir)/src --pkg geoformats-1.0 $^
	touch $@

tests_LDADD = $(LIBGEOFORMATS_LIBS) $(top_srcdir)/src/libgeoformats.la

CLEANFILES = \
	$(BUILT_SOURCES) \
	$(tests_VALASOURCES:.vala=.c)

EXTRA_DIST = $(tests_VALASOURCES)
