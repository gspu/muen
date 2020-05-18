IMG_NAME = muen.iso
IMG_SRC  = $(CURDIR)/../emulate/$(IMG_NAME)
HTTP_DIR = $(CURDIR)/http

TARGET_PWR_MECH ?= amt

TARGET_START    ?= target_start_$(TARGET_PWR_MECH)
TARGET_SHUTDOWN ?= target_shutdown_$(TARGET_PWR_MECH)

LIGHTTPD_CMD ?= /usr/sbin/lighttpd
PING_CMD     ?= ping -c 3
DEPLOY_PORT  ?= 8000
TARGET_IP    ?= 192.168.254.2

TARGET_EGNAME ?= eg1
TARGET_EPCIP  ?= 192.168.254.254

all: deploy

deploy: .server $(HTTP_DIR)/boot.cfg $(HTTP_DIR)/$(IMG_NAME) $(TARGET_START)

shutdown: $(TARGET_SHUTDOWN)

$(HTTP_DIR):
	mkdir -p $(HTTP_DIR)

$(HTTP_DIR)/$(IMG_NAME): $(IMG_SRC) | $(HTTP_DIR)
	cp $< $@
$(HTTP_DIR)/boot.cfg: boot.cfg | $(HTTP_DIR)
	cp $< $@

lighttpd.conf: lighttpd_conf.src
	sed -r 's#__SERVERROOT__#$(CURDIR)#g' $< > $@

.server: lighttpd.conf
	$(LIGHTTPD_CMD) -f lighttpd.conf

clean:
	@kill `cat .server 2>/dev/null` 2>/dev/null || true
	@rm -f .server lighttpd.*
	@rm -rf $(HTTP_DIR)

target_start_amt:
	$(PING_CMD) $(TARGET_IP) >/dev/null
	./start_shutdown_amtc.sh $(TARGET_IP) start

target_shutdown_amt:
	./start_shutdown_amtc.sh $(TARGET_IP) shutdown

target_start_egctl:
	./start_shutdown_egctl.sh $(TARGET_EGNAME) start

target_shutdown_egctl:
	./start_shutdown_egctl.sh $(TARGET_EGNAME) shutdown

target_start_epc:
	./start_shutdown_epc.sh $(TARGET_EPCIP) start

target_shutdown_epc:
	./start_shutdown_epc.sh $(TARGET_EPCIP) shutdown
