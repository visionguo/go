package k8s_cost

import (
	"fmt"
	"math"
	"strconv"
	"strings"
)

const (
	_ = iota
	_
	Mi float64 = 1 << (10 * iota)
)

//memory type
type Memory struct {
	m float64
}

//initial memory
func Mem() Memory {
	return Memory{0}
}

//memory string
func MemFromString(m string) (Memory, error) {
	f, err := memToFloat64(m)
	if err != nil {
		return Memory{}, err
	}
	return Memory{f}, nil
}

//initial Mem
func MemFromFloat(m float64) Memory {
	return Memory{m}
}

//express of minus m
func (s Memory) Sub(m string) (Memory, error) {
	f, err := memToFloat64(m)
	if err != nil {
		return Memory{}, err
	}
	return Memory{s.m - f}, nil
}

//express of plus m
func (s Memory) AddF(m float64) Memory {
	return Memory{s.m + m}
}

//express of minus m
func (s Memory) SubF(m float64) Memory {
	return Memory{s.m - m}
}

//string
func (s Memory) ToString() string {
	return float64ToMi(s.m)
}

//float
func (s Memory) ToFloat64() float64 {
	return s.m
}

func memToFloat64(s string) (float64, error) {
	switch {
	case strings.HasSuffix(s, "Mi"):
		mem, err := strconv.ParseFloat(strings.TrimSuffix(s, "Mi"), 64)
		if err != nil {
			return 0, fmt.Errorf("Failed to convert memory string %s to float", s)
		}
		return mem * Mi, nil
	case strings.HasSuffix(s, "Gi"):
		mem, err := strconv.ParseFloat(strings.TrimSuffix(s, "Gi"), 64)
		if err != nil {
			return 0, fmt.Errorf("failed to convert memory string %s to float", s)
		}
		return mem * Gi, nil
	default:
		return 0, fmt.Errorf("failed to convert memory string %s to float, unknown units", s)
	}
}

func float64ToMi(m float64) string {
	return fmt.Sprintf("%dMi", int(math.Ceil(m/Mi)))
}
