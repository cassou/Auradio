LIST := list.json
IDS != jq -r '.[].id' $(LIST)
PLAY_FILES := $(addprefix play/,$(IDS))

.PHONY: all clean

all: $(PLAY_FILES)

play/%: $(LIST)
	@mkdir -p play
	@jq -c --arg id "$*" '[.[] | select(.id == $$id) | .url]' $(LIST) > $@

clean:
	rm -rf play
