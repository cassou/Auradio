LIST := list.json
IDS != jq -r '.[].id' $(LIST)
PLAY_FILES := $(addprefix play/,$(IDS))
PORT ?= 8000
SERVICE_NAME ?= auradio.service
SYSTEMD_DIR ?= /etc/systemd/system

.PHONY: all clean serve install-systemd uninstall-systemd

all: $(PLAY_FILES)

play/%: $(LIST)
	@mkdir -p play
	@jq -c --arg id "$*" '[.[] | select(.id == $$id) | .url]' $(LIST) > $@

serve: all
	python3 -m http.server $(PORT) --bind 0.0.0.0

install-systemd:
	sudo install -m 0644 $(SERVICE_NAME) $(SYSTEMD_DIR)/$(SERVICE_NAME)
	sudo systemctl daemon-reload
	sudo systemctl enable --now $(SERVICE_NAME)

uninstall-systemd:
	-sudo systemctl disable --now $(SERVICE_NAME)
	sudo rm -f $(SYSTEMD_DIR)/$(SERVICE_NAME)
	sudo systemctl daemon-reload

clean:
	rm -rf play
