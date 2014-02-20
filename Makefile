all: index.html design.html download.html modules.html usage.html hints.html testing.html

%.html: %.php _head.php _foot.php
	php $< > $@
