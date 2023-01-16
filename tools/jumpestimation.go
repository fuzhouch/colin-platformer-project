package main

import "fmt"

var (
	FRAMES_PER_SECOND = 60
	GRID              = 64
)

// computeDistance computes distance based on intiail speed and gravity.
// Gravity is represented as a delta of speed. The speed unit is
// pixel/second.
func computeDistance(initialSpeed float64, gravity float64) (totalFrames int, totalDistance float64) {
	totalDistance = 0
	totalFrames = int(initialSpeed / gravity)
	for i := 0; i < totalFrames; i += 1 {
		// Convert speed/sec to speed/frame
		currentSpeed := initialSpeed - gravity*float64(i)
		currentSpeedPerFrame := currentSpeed / float64(FRAMES_PER_SECOND)
		distancePerFrame := currentSpeedPerFrame
		totalDistance += distancePerFrame
	}
	return
}

func computeAcceleratedDistance(initialSpeed float64,
	accerlation float64,
	useFormular bool) (totalFrames int, totalDistance float64) {

	if useFormular {
		totalFrames = int(initialSpeed / accerlation)
		seconds := initialSpeed / accerlation / float64(FRAMES_PER_SECOND)
		totalDistance = initialSpeed*seconds - 0.5*accerlation*seconds*seconds
		fmt.Printf("%f\n", seconds)
	} else {
		totalFrames = 0
		currentSpeed := initialSpeed
		for currentSpeed > 0 {
			// Convert speed/sec to speed/frame
			currentSpeed = currentSpeed - accerlation
			currentSpeedPerFrame := currentSpeed / float64(FRAMES_PER_SECOND)
			distancePerFrame := currentSpeedPerFrame
			totalDistance += distancePerFrame
			totalFrames += 1
		}
	}
	return
}

func main() {
	totalFrames, totalDistance := computeDistance(1000, 40)
	totalGrids := totalDistance / float64(GRID)
	fmt.Printf("simple speed: frames: %d, grids(including curernt stand): %f, distance (pixel): %f\n",
		totalFrames,
		totalGrids,
		totalDistance)

	totalFrames, totalDistance = computeAcceleratedDistance(1000, 40, true)
	totalGrids = totalDistance / float64(GRID)
	fmt.Printf("Acceleration(useFormular): frames: %d, grids(including curernt stand): %f, distance (pixel): %f\n",
		totalFrames,
		totalGrids,
		totalDistance)

	totalFrames, totalDistance = computeAcceleratedDistance(1000, 40, false)
	totalGrids = totalDistance / float64(GRID)
	fmt.Printf("Acceleration(per-frame, Godot behavior): frames: %d, grids(including curernt stand): %f, distance (pixel): %f\n",
		totalFrames,
		totalGrids,
		totalDistance)
}
