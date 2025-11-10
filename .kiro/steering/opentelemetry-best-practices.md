## OpenTelemetry Best Practices

### Overview

OpenTelemetry is a vendor-neutral, open-source observability framework for cloud-native software. It provides a unified way to collect traces, metrics, and logs from applications and infrastructure.

**Core Components:**

- **Traces**: Track requests as they flow through distributed systems
- **Metrics**: Measure application and system performance
- **Logs**: Capture detailed event information
- **Collector**: Receive, process, and export telemetry data
- **Exporters**: Send data to observability backends

### Architecture Patterns

**Direct Export Pattern**

```
Application → OTLP Exporter → Observability Backend
```

- Simple setup for development and small deployments
- Application exports directly to backend (Jaeger, Prometheus, etc.)
- Lower latency but couples application to backend

**Collector Pattern (Recommended for Production)**

```
Application → OTLP Exporter → OTel Collector → Observability Backend(s)
```

- Decouples applications from backends
- Centralized processing, filtering, and routing
- Supports multiple backends simultaneously
- Better resource management and retry logic

### Instrumentation Best Practices

**Service Identification**

```python
from opentelemetry.sdk.resources import SERVICE_NAME, Resource

# Always define service name and version
resource = Resource.create(attributes={
    SERVICE_NAME: "my-service",
    "service.version": "1.0.0",
    "deployment.environment": "production",
    "service.namespace": "backend"
})
```

**Tracer Setup**

```python
from opentelemetry import trace
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter

# Initialize tracer provider with resource
tracer_provider = TracerProvider(resource=resource)

# Use batch processor for better performance
span_processor = BatchSpanProcessor(
    OTLPSpanExporter(endpoint="http://collector:4317")
)
tracer_provider.add_span_processor(span_processor)

# Set as global tracer provider
trace.set_tracer_provider(tracer_provider)

# Get tracer with instrumentation scope
tracer = trace.get_tracer(
    instrumenting_module_name="my.service.module",
    instrumenting_library_version="1.0.0"
)
```

**Creating Spans**

```python
from opentelemetry import trace
from opentelemetry.trace import Status, StatusCode, SpanKind

tracer = trace.get_tracer(__name__)

def process_request(request_id):
    # Use descriptive span names (operation, not URL)
    with tracer.start_as_current_span(
        "process_user_request",
        kind=SpanKind.SERVER,
        attributes={
            "request.id": request_id,
            "user.id": get_user_id(),
        }
    ) as span:
        try:
            result = do_work()
            
            # Add attributes during execution
            span.set_attribute("result.count", len(result))
            
            # Set status on success
            span.set_status(Status(StatusCode.OK))
            return result
            
        except Exception as e:
            # Record exceptions
            span.record_exception(e)
            span.set_status(Status(StatusCode.ERROR, str(e)))
            raise
```

**Span Kinds**

- `INTERNAL`: Default, for internal operations
- `SERVER`: Entry point for server-side request handling
- `CLIENT`: Outgoing requests to external services
- `PRODUCER`: Message queue producers
- `CONSUMER`: Message queue consumers

### Metrics Best Practices

**Meter Setup**

```python
from opentelemetry import metrics
from opentelemetry.sdk.metrics import MeterProvider
from opentelemetry.sdk.metrics.export import PeriodicExportingMetricReader
from opentelemetry.exporter.otlp.proto.grpc.metric_exporter import OTLPMetricExporter

# Configure metric reader with export interval
reader = PeriodicExportingMetricReader(
    OTLPMetricExporter(endpoint="http://collector:4317"),
    export_interval_millis=60000  # Export every 60 seconds
)

meter_provider = MeterProvider(
    resource=resource,
    metric_readers=[reader]
)
metrics.set_meter_provider(meter_provider)

# Get meter
meter = metrics.get_meter(
    instrumenting_module_name="my.service.module",
    instrumenting_library_version="1.0.0"
)
```

**Metric Instruments**

```python
# Counter: Monotonically increasing value
request_counter = meter.create_counter(
    name="http.server.requests",
    description="Total HTTP requests",
    unit="1"
)
request_counter.add(1, {"http.method": "GET", "http.status_code": 200})

# UpDownCounter: Can increase or decrease
active_connections = meter.create_up_down_counter(
    name="http.server.active_connections",
    description="Active HTTP connections",
    unit="1"
)
active_connections.add(1)  # Connection opened
active_connections.add(-1)  # Connection closed

# Histogram: Distribution of values
request_duration = meter.create_histogram(
    name="http.server.duration",
    description="HTTP request duration",
    unit="ms"
)
request_duration.record(125.5, {"http.method": "POST", "http.route": "/api/users"})

# Asynchronous Gauge: Observe current value
def get_memory_usage():
    return {"memory.usage": get_current_memory()}

meter.create_observable_gauge(
    name="process.runtime.memory.usage",
    callbacks=[lambda options: [Observation(get_current_memory())]],
    description="Current memory usage",
    unit="bytes"
)
```

**Metric Naming Conventions**

- Use dot notation: `http.server.duration`
- Start with namespace: `http`, `db`, `system`, `process`
- Be specific but concise
- Use plural for counts: `http.server.requests`
- Use singular for measurements: `http.server.duration`

### Logging Best Practices

**Log Correlation**

```python
import logging
from opentelemetry import trace
from opentelemetry.sdk._logs import LoggerProvider, LoggingHandler
from opentelemetry.sdk._logs.export import BatchLogRecordProcessor
from opentelemetry.exporter.otlp.proto.grpc._log_exporter import OTLPLogExporter

# Setup OpenTelemetry logging
logger_provider = LoggerProvider(resource=resource)
logger_provider.add_log_record_processor(
    BatchLogRecordProcessor(OTLPLogExporter(endpoint="http://collector:4317"))
)

# Attach to Python logging
handler = LoggingHandler(logger_provider=logger_provider)
logging.getLogger().addHandler(handler)

# Logs will automatically include trace context
logger = logging.getLogger(__name__)
logger.info("Processing request", extra={"user.id": user_id})
```

**Structured Logging**

```python
# Use structured attributes instead of string formatting
logger.info(
    "User login successful",
    extra={
        "user.id": user_id,
        "user.email": user_email,
        "login.method": "oauth",
        "login.provider": "google"
    }
)

# Avoid string interpolation
# BAD: logger.info(f"User {user_id} logged in")
# GOOD: logger.info("User logged in", extra={"user.id": user_id})
```

### OpenTelemetry Collector Configuration

**Basic Collector Setup**

```yaml
# collector-config.yaml
receivers:
  otlp:
    protocols:
      grpc:
        endpoint: 0.0.0.0:4317
      http:
        endpoint: 0.0.0.0:4318

processors:
  # Batch telemetry for efficiency
  batch:
    timeout: 10s
    send_batch_size: 1024
  
  # Limit memory usage
  memory_limiter:
    check_interval: 1s
    limit_mib: 512
    spike_limit_mib: 128
  
  # Add resource attributes
  resource:
    attributes:
      - key: deployment.environment
        value: production
        action: upsert
  
  # Sample traces (optional)
  probabilistic_sampler:
    sampling_percentage: 10

exporters:
  # OTLP to backend
  otlp:
    endpoint: backend:4317
    tls:
      insecure: false
      cert_file: /etc/certs/cert.pem
      key_file: /etc/certs/key.pem
  
  # Debug exporter for troubleshooting
  debug:
    verbosity: detailed
  
  # Prometheus for metrics
  prometheus:
    endpoint: 0.0.0.0:8889

service:
  pipelines:
    traces:
      receivers: [otlp]
      processors: [memory_limiter, batch, resource]
      exporters: [otlp, debug]
    
    metrics:
      receivers: [otlp]
      processors: [memory_limiter, batch, resource]
      exporters: [otlp, prometheus]
    
    logs:
      receivers: [otlp]
      processors: [memory_limiter, batch, resource]
      exporters: [otlp]
  
  telemetry:
    logs:
      level: info
    metrics:
      address: 0.0.0.0:8888
```

**File-based Log Collection**

```yaml
receivers:
  filelog:
    include: [/var/log/app/*.log]
    start_at: end
    operators:
      # Parse JSON logs
      - type: json_parser
        timestamp:
          parse_from: attributes.timestamp
          layout: '%Y-%m-%dT%H:%M:%S.%fZ'
        severity:
          parse_from: attributes.level
      
      # Extract fields
      - type: move
        from: attributes.message
        to: body

exporters:
  otlp:
    endpoint: backend:4317

service:
  pipelines:
    logs:
      receivers: [filelog]
      processors: [batch]
      exporters: [otlp]
```

### Environment Variables Configuration

**Standard Environment Variables**

```bash
# Service identification
export OTEL_SERVICE_NAME="my-service"
export OTEL_RESOURCE_ATTRIBUTES="service.version=1.0.0,deployment.environment=production"

# Exporter configuration
export OTEL_EXPORTER_OTLP_ENDPOINT="http://collector:4318"
export OTEL_EXPORTER_OTLP_PROTOCOL="http/protobuf"  # or "grpc"

# Signal-specific endpoints
export OTEL_EXPORTER_OTLP_TRACES_ENDPOINT="http://collector:4318/v1/traces"
export OTEL_EXPORTER_OTLP_METRICS_ENDPOINT="http://collector:4318/v1/metrics"
export OTEL_EXPORTER_OTLP_LOGS_ENDPOINT="http://collector:4318/v1/logs"

# Authentication
export OTEL_EXPORTER_OTLP_HEADERS="api-key=your-api-key"

# Exporter selection
export OTEL_TRACES_EXPORTER="otlp"
export OTEL_METRICS_EXPORTER="otlp"
export OTEL_LOGS_EXPORTER="otlp"

# Sampling
export OTEL_TRACES_SAMPLER="parentbased_traceidratio"
export OTEL_TRACES_SAMPLER_ARG="0.1"  # 10% sampling

# Batch processor configuration
export OTEL_BSP_SCHEDULE_DELAY="5000"  # 5 seconds
export OTEL_BSP_MAX_QUEUE_SIZE="2048"
export OTEL_BSP_MAX_EXPORT_BATCH_SIZE="512"
```

### Semantic Conventions

**HTTP Spans**

```python
# Follow semantic conventions for HTTP
span.set_attributes({
    "http.method": "GET",
    "http.url": "https://api.example.com/users/123",
    "http.target": "/users/123",
    "http.host": "api.example.com",
    "http.scheme": "https",
    "http.status_code": 200,
    "http.user_agent": "Mozilla/5.0...",
    "http.route": "/users/{id}",  # Template, not actual value
})
```

**Database Spans**

```python
span.set_attributes({
    "db.system": "postgresql",
    "db.name": "users_db",
    "db.statement": "SELECT * FROM users WHERE id = ?",
    "db.operation": "SELECT",
    "db.user": "app_user",
    "net.peer.name": "db.example.com",
    "net.peer.port": 5432,
})
```

**RPC/gRPC Spans**

```python
span.set_attributes({
    "rpc.system": "grpc",
    "rpc.service": "UserService",
    "rpc.method": "GetUser",
    "rpc.grpc.status_code": 0,  # OK
    "net.peer.name": "service.example.com",
    "net.peer.port": 50051,
})
```

### Performance Optimization

**Batch Processing**

```python
# Use batch processors for better performance
from opentelemetry.sdk.trace.export import BatchSpanProcessor

processor = BatchSpanProcessor(
    exporter,
    max_queue_size=2048,
    schedule_delay_millis=5000,
    max_export_batch_size=512,
    export_timeout_millis=30000
)
```

**Sampling Strategies**

```python
from opentelemetry.sdk.trace.sampling import (
    TraceIdRatioBased,
    ParentBased,
    ALWAYS_ON,
    ALWAYS_OFF
)

# Sample 10% of traces
sampler = ParentBased(root=TraceIdRatioBased(0.1))

tracer_provider = TracerProvider(
    resource=resource,
    sampler=sampler
)
```

**Conditional Instrumentation**

```python
# Only record expensive attributes when span is recording
if span.is_recording():
    expensive_data = compute_expensive_data()
    span.set_attribute("expensive.data", expensive_data)
```

### Context Propagation

**W3C Trace Context (Default)**

```python
# Automatic context propagation with HTTP requests
import requests
from opentelemetry.instrumentation.requests import RequestsInstrumentor

RequestsInstrumentor().instrument()

# Context automatically propagated in headers:
# traceparent: 00-{trace-id}-{span-id}-{flags}
# tracestate: vendor1=value1,vendor2=value2
```

**Manual Context Propagation**

```python
from opentelemetry import trace
from opentelemetry.propagate import inject, extract

# Inject context into carrier (e.g., HTTP headers)
carrier = {}
inject(carrier)
# carrier now contains: {'traceparent': '00-...', 'tracestate': '...'}

# Extract context from carrier
ctx = extract(carrier)
with trace.use_span(trace.get_current_span(), end_on_exit=False):
    # Continue trace
    pass
```

### Error Handling and Debugging

**Exception Recording**

```python
try:
    risky_operation()
except Exception as e:
    # Record exception with full stack trace
    span.record_exception(e)
    span.set_status(Status(StatusCode.ERROR, str(e)))
    
    # Add context
    span.set_attribute("error.type", type(e).__name__)
    span.set_attribute("error.handled", True)
    raise
```

**Debug Exporter**

```python
# Use console exporter for development
from opentelemetry.sdk.trace.export import ConsoleSpanExporter

tracer_provider.add_span_processor(
    BatchSpanProcessor(ConsoleSpanExporter())
)
```

**Collector Debugging**

```yaml
# Enable detailed logging in collector
exporters:
  debug:
    verbosity: detailed

service:
  telemetry:
    logs:
      level: debug
```

### Security Best Practices

**Sensitive Data**

```python
# Never log sensitive information
# BAD
span.set_attribute("user.password", password)
span.set_attribute("credit_card.number", cc_number)

# GOOD - Use identifiers only
span.set_attribute("user.id", user_id)
span.set_attribute("payment.method", "credit_card")
```

**TLS Configuration**

```yaml
# Collector with TLS
exporters:
  otlp:
    endpoint: backend:4317
    tls:
      insecure: false
      cert_file: /etc/certs/cert.pem
      key_file: /etc/certs/key.pem
      ca_file: /etc/certs/ca.pem
```

**Authentication**

```bash
# API key authentication
export OTEL_EXPORTER_OTLP_HEADERS="Authorization=Bearer your-token"

# Multiple headers
export OTEL_EXPORTER_OTLP_HEADERS="api-key=key123,x-tenant-id=tenant456"
```

### Testing and Validation

**In-Memory Exporter for Tests**

```python
from opentelemetry.sdk.trace.export import SimpleSpanProcessor
from opentelemetry.sdk.trace.export.in_memory_span_exporter import InMemorySpanExporter

# Setup test exporter
test_exporter = InMemorySpanExporter()
tracer_provider.add_span_processor(SimpleSpanProcessor(test_exporter))

# Run test
with tracer.start_as_current_span("test_operation"):
    do_something()

# Verify spans
spans = test_exporter.get_finished_spans()
assert len(spans) == 1
assert spans[0].name == "test_operation"
assert spans[0].attributes["custom.attribute"] == "expected_value"

# Clear for next test
test_exporter.clear()
```

**Collector Validation**

```bash
# Validate collector configuration
otelcol validate --config=collector-config.yaml

# Test with debug exporter
# Check collector logs for exported data
docker logs otel-collector | grep -A 20 "Span"
```

### Common Patterns

**Database Query Instrumentation**

```python
def execute_query(query, params):
    with tracer.start_as_current_span(
        "db.query",
        kind=SpanKind.CLIENT,
        attributes={
            "db.system": "postgresql",
            "db.statement": query,
            "db.operation": query.split()[0].upper(),
        }
    ) as span:
        start_time = time.time()
        try:
            result = db.execute(query, params)
            span.set_attribute("db.rows_affected", result.rowcount)
            return result
        finally:
            duration_ms = (time.time() - start_time) * 1000
            span.set_attribute("db.duration_ms", duration_ms)
```

**HTTP Client Instrumentation**

```python
def make_http_request(url, method="GET"):
    with tracer.start_as_current_span(
        f"HTTP {method}",
        kind=SpanKind.CLIENT,
        attributes={
            "http.method": method,
            "http.url": url,
        }
    ) as span:
        response = requests.request(method, url)
        span.set_attributes({
            "http.status_code": response.status_code,
            "http.response_content_length": len(response.content),
        })
        return response
```

**Background Job Instrumentation**

```python
def process_job(job_id):
    with tracer.start_as_current_span(
        "job.process",
        kind=SpanKind.INTERNAL,
        attributes={
            "job.id": job_id,
            "job.type": "data_processing",
        }
    ) as span:
        try:
            result = process_data(job_id)
            span.set_attribute("job.status", "completed")
            span.set_attribute("job.items_processed", result.count)
        except Exception as e:
            span.record_exception(e)
            span.set_attribute("job.status", "failed")
            raise
```

### Deployment Considerations

**Kubernetes Deployment**

```yaml
# Deploy collector as DaemonSet for node-level collection
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: otel-collector
spec:
  selector:
    matchLabels:
      app: otel-collector
  template:
    metadata:
      labels:
        app: otel-collector
    spec:
      containers:
      - name: otel-collector
        image: otel/opentelemetry-collector:latest
        env:
        - name: OTEL_RESOURCE_ATTRIBUTES
          value: "k8s.cluster.name=production,k8s.namespace.name=$(NAMESPACE)"
        volumeMounts:
        - name: config
          mountPath: /etc/otel
      volumes:
      - name: config
        configMap:
          name: otel-collector-config
```

**Resource Detection**

```yaml
# Automatically detect cloud/container resources
processors:
  resourcedetection:
    detectors: [env, system, docker, ec2, ecs, eks, gcp, azure]
    timeout: 5s
    override: false
```

### Monitoring the Collector

**Collector Metrics**

```yaml
# Enable collector self-monitoring
service:
  telemetry:
    metrics:
      address: 0.0.0.0:8888
      level: detailed
```

**Key Metrics to Monitor**

- `otelcol_receiver_accepted_spans`: Spans received
- `otelcol_receiver_refused_spans`: Spans rejected
- `otelcol_exporter_sent_spans`: Spans successfully exported
- `otelcol_exporter_send_failed_spans`: Export failures
- `otelcol_processor_batch_batch_send_size`: Batch sizes
- `otelcol_process_runtime_total_sys_memory_bytes`: Memory usage
