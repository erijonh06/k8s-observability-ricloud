using Prometheus;
using System.Threading;

var counter = Metrics.CreateCounter("worker_jobs_total", "Number of processed jobs");

while (true)
{
    counter.Inc();
    Thread.Sleep(1000); // Simulate job processing
}
