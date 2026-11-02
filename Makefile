VC = iverilog
SIM = vvp

SRC_DIR = src
TB_DIR = testbench
BUILD_DIR = build

TB ?= ps2_receiver_tb

DESIGN_SRCS = $(wildcard $(SRC_DIR)/*.v)
TB_SRCS = $(wildcard $(TB_DIR)/*_tb.v)

OUT = $(BUILD_DIR)/$(TB).vvp
ALL_VVPS = $(patsubst $(TB_DIR)/%.v, $(BUILD_DIR)/%.vvp, $(TB_SRCS))

all: $(OUT)

$(BUILD_DIR)/%.vvp: $(TB_DIR)/%.v $(DESIGN_SRCS)
	@mkdir -p $(BUILD_DIR)
	$(VC) -o $@ $^

run: $(OUT)
	$(SIM) $(OUT)

test-all: $(ALL_VVPS)
	@for vvp in $(ALL_VVPS); do \
		echo "Running $$vvp"; \
		$(SIM) $$vvp; \
	done

clean:
	rm -rf $(BUILD_DIR)

.PHONY: all run test-all clean
