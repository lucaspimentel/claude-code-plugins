---
description: Create a new auto-instrumentation integration
---

Create a new auto-instrumentation integration for the Datadog .NET tracer.

Follow these steps:

1. **Gather requirements**:
   - Target library name and NuGet package
   - Supported version range
   - Methods to instrument (assembly, type, method signatures)
   - Integration category (e.g., HTTP, Database, Messaging, etc.)

2. **Create integration class**:
   - Location: `tracer/src/Datadog.Trace/ClrProfiler/AutoInstrumentation/<Area>/<Integration>.cs`
   - Add `[InstrumentMethod]` attribute with:
     - `AssemblyName`: Target assembly
     - `TypeName`: Fully qualified type name
     - `MethodName`: Method to instrument
     - `ReturnTypeName`: Method return type
     - `ParameterTypeNames`: Array of parameter types
     - `MinimumVersion` and `MaximumVersion`: Version range
     - `IntegrationName`: Unique integration identifier
   - Implement `OnMethodBegin` (for method entry)
   - Implement `OnMethodEnd` or `OnAsyncMethodEnd` (for method exit)

3. **Use duck typing for third-party types**:
   - Define interface with required properties/methods
   - Use `where TTarget : IMyInterface, IDuckType` constraint
   - Or use `target.DuckCast<IMyInterface>()` for runtime casting

4. **Add integration tests**:
   - Location: `tracer/test/Datadog.Trace.ClrProfiler.IntegrationTests/<Area>/`
   - Create sample application: `tracer/test/test-applications/integrations/<Library>/`
   - Test multiple library versions (package_versions.props)
   - Verify spans are created with correct tags

5. **Generate boilerplate**:
   - Run: `./tracer/build.ps1 RunInstrumentationGenerator`

6. **Update documentation**:
   - Add integration to supported libraries list if needed

Reference files:
- `docs/development/AutomaticInstrumentation.md` - Complete integration guide
- `docs/development/DuckTyping.md` - Duck typing patterns
- `tracer/src/Datadog.Trace/ClrProfiler/AutoInstrumentation/` - Existing integrations

After creating:
- Run the instrumentation generator
- Build the tracer
- Run integration tests
- Verify spans in test output
