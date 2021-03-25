package monitor_test

import (
	"testing"

	"github.com/PrathyushaLakkireddy/solana-prometheus/config"
	"github.com/PrathyushaLakkireddy/solana-prometheus/monitor"
)

func TestGetNodeHealth(t *testing.T) {
	cfg, err := config.ReadFromFile()
	if err != nil {
		t.Error("Error while reading config :", err)
	}
	res, err := monitor.GetNodeHealth(cfg)
	if err != nil {
		t.Error("Error while fetching Node Health")
	}
	if &res == nil {
		t.Error("Expected OK, but got empty result: ", res)
	}
	if &res != nil {
		t.Log("Got Node Health", res)
	}
}
