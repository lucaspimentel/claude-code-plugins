---
description: Find an existing integration in the tracer
---

Find an existing auto-instrumentation integration in the Datadog .NET tracer.

Search strategies:
1. **By library name**: Search for the library name in integration files
2. **By technology**: Look in specific directories under `tracer/src/Datadog.Trace/ClrProfiler/AutoInstrumentation/`
3. **By assembly**: Search for `[InstrumentMethod(AssemblyName = "...")]` attributes

Available integration categories:
- **AdoNet** - Database drivers (SqlClient, MySql, Npgsql, etc.)
- **AspNet** / **AspNetCore** - ASP.NET web frameworks
- **AWS** - AWS SDK integrations
- **Azure** - Azure SDK integrations
- **Couchbase** - Couchbase client
- **Elasticsearch** - Elasticsearch client
- **GraphQL** - GraphQL libraries
- **Grpc** - gRPC client/server
- **Http** - HttpClient and related
- **IbmMq** - IBM MQ client
- **Kafka** - Kafka client
- **Logging** - Logging frameworks (Serilog, NLog, log4net)
- **MongoDb** - MongoDB client
- **Msmq** - MSMQ messaging
- **OpenTelemetry** - OpenTelemetry interop
- **Process** - Process execution
- **RabbitMQ** - RabbitMQ client
- **Redis** - Redis clients (StackExchange.Redis, ServiceStack.Redis)
- **Remoting** - .NET Remoting
- **Testing** - Test frameworks (xUnit, NUnit, MSTest)
- **Wcf** - WCF services

After finding:
- Show the integration file path with line numbers
- Display the `[InstrumentMethod]` attributes
- Show which methods are instrumented
- Identify the supported version range
- Link to integration tests if available
