package main

import (
"context"
"fmt"
"log"
"math/rand"
"os"        // [[Add]]
"time"

"contrib.go.opencensus.io/exporter/stackdriver"   // [[Add]]
"go.opencensus.io/stats"
"go.opencensus.io/stats/view"

monitoredrespb "google.golang.org/genproto/googleapis/api/monitoredres" // [[Add]]
)

var videoServiceInputQueueSize = stats.Int64(
"my.videoservice.org/measure/input_queue_size",
"Number of videos queued up in the input queue",
stats.UnitDimensionless)

func main() {
// [[Add block]]
// Setup metrics exporting to Stackdriver.
exporter, err := stackdriver.NewExporter(stackdriver.Options{
ProjectID: os.Getenv("MY_PROJECT_ID"),
Resource: &monitoredrespb.MonitoredResource {
Type: "gce_instance",
Labels: map[string]string {
"instance_id": os.Getenv("MY_GCE_INSTANCE_ID"),
"zone": os.Getenv("MY_GCE_INSTANCE_ZONE"),
},
},
})
if err != nil {
log.Fatalf("Cannot setup Stackdriver exporter: %v", err)
}
view.RegisterExporter(exporter)
// [[End: add block]]

ctx := context.Background()

// Setup a view so that we can export our metric.
if err := view.Register(&view.View{
Name: "my.videoservice.org/measure/input_queue_size",
Description: "Number of videos queued up in the input queue",
Measure: videoServiceInputQueueSize,
Aggregation: view.LastValue(),
}); err != nil {
log.Fatalf("Cannot setup view: %v", err)
}
// Set the reporting period to be once per second.
view.SetReportingPeriod(1 * time.Second)

// Here’s our fake video processing application. Every second, it
// checks the length of the input queue (e.g., number of videos
// waiting to be processed) and records that information.
for {
time.Sleep(1 * time.Second)
queueSize := getQueueSize()

// Record the queue size.
stats.Record(ctx, videoServiceInputQueueSize.M(queueSize))
fmt.Println("Queue size: ", queueSize)
}
}

func getQueueSize() (int64) {
// Fake out a queue size here by returning a random number between
// 1 and 100.
return rand.Int63n(100) + 1
}
