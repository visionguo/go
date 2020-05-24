package k8s_cost

import (
	"fmt"
	"strconv"
	"strings"
)

//define cpu type
type CPU struct {
	millicores int
}

//initialized cpu at 0
func InitialCPU() CPU {
	return CPU{0}
}

//cpu string
func CPUFromString(c string) (CPU, error) {
	cpu, err := cpuIntFromString(c)
	if err != nil {
		return CPU{}, err
	}
	return CPU{cpu}, nil
}

//cpu float
func CPUFromFloat(c float64) CPU {
	return CPU{int(c * 1000)}
}

//Add express
func (cpu CPU) Add(c string) (CPU, error) {
	ci, err := cpuIntFromString(c)
	if err != nil {
		return CPU{}, err
	}
	return CPU{cpu.millicores + ci}, nil
}

//Sub express
func (cpu CPU) Sub(c string) (CPU, error) {
	ci, err := cpuIntFromString(c)
	if err != nil {
		return CPU{}, err
	}
	return CPU{cpu.millicores - ci}, nil
}

//sum express
func (cpu CPU) AddF(c float64) CPU {
	return CPU{cpu.millicores + int(c*1000)}
}

//minus express
func (cpu CPU) SubF(c float64) CPU {
	return CPU{cpu.millicores - int(c*1000)}
}

//rounded to the nearest milicore
func (cpu CPU) ToString() string {
	return fmt.Sprintf("%dm", cpu.millicores)
}

//float
// (e.g: 500m = 0.5)
func (cpu CPU) ToFloat64() float64 {
	return float64(cpu.millicores) / 1000
}

//return the CPU value as an int
func (cpu CPU) ToMillicores() int {
	return cpu.millicores
}

func cpuIntFromString(s string) (int, error) {
	switch {
	case strings.HasSuffix(s, "m"):
		i, err := strconv.Atoi(strings.TrimSuffix(s, "m"))
		if err != nil {
			return 0, fmt.Errorf("unknown cpu format: %s", s)
		}
		return i, nil
	default:
		f, err := strconv.ParseFloat(s, 64)
		if err != nil {
			return 0, fmt.Errorf("unknown cpu format: %s", s)
		}
		return int(f * 1000), nil
	}
}
