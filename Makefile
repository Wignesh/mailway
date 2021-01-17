VERSION = 1.0.0
DIST = $(PWD)/dist

.PHONY: clean
clean:
	rm -rf $(DIST) *.deb

$(DIST)/mailway:
	mkdir -p $(DIST)
	cd ./cmd/mailway && \
		go build -o $(DIST)/usr/local/sbin/mailway

.PHONY: deb
deb: $(DIST)/mailway
	mkdir -p \
		$(DIST)/etc/cron.daily \
		$(DIST)/etc/mailway \
		$(DIST)/etc/mailway/conf.d \
		$(DIST)/etc/mailway/frontline \
		$(DIST)/etc/systemd/system/
	cp ./frontline/* $(DIST)/etc/mailway/frontline
	cp ./conf.d/* $(DIST)/etc/mailway/conf.d
	cp ./systemd/* $(DIST)/etc/systemd/system/
	cp ./key.pub $(DIST)/etc/mailway
	cp ./spamc.py $(DIST)/usr/local/spamc.py
	cp ./cron.daily/* $(DIST)/etc/cron.daily
	chmod +x $(DIST)/usr/local/spamc.py
	fpm -n mailway -s dir -t deb --chdir=$(DIST) --version=$(VERSION) \
		--after-install ./after-install.sh \
		--depends frontline \
		--depends auth \
		--depends forwarding \
		--depends mailout \
		--depends maildb

