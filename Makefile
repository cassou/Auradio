LIST := list.json
IDS != jq -r '.[].id' $(LIST)
PLAY_FILES := $(addprefix play/,$(IDS))
PORT ?= 8000

.PHONY: all clean serve

all: $(PLAY_FILES)

play/%: $(LIST)
	@mkdir -p play
	@jq -c --arg id "$*" '[.[] | select(.id == $$id) | .url]' $(LIST) > $@

serve: all
	python3 -m http.server $(PORT) --bind 0.0.0.0

clean:
	rm -rf play
