# MCP Builder

Guide for creating high-quality MCP (Model Context Protocol) servers in Python (FastMCP) or Node/TypeScript.

## When to Use

Use this skill when:
- Creating MCP servers for Claude integration
- Building custom tools for Claude to use
- Exposing APIs or data sources to Claude
- Integrating Claude with external systems
- Developing reusable MCP components
- Testing and debugging MCP servers
- Deploying MCP servers to production

## Key Concepts

### MCP Architecture
- **Server**: Exposes tools and resources to Claude
- **Client**: Claude's MCP client
- **Tools**: Callable functions with inputs/outputs
- **Resources**: Persistent data (files, databases)
- **Prompts**: Templates for Claude responses

### MCP Protocol
- JSON-RPC 2.0 communication
- Tool invocation via server
- Streaming responses support
- Resource access patterns
- Schema validation for tools

## FastMCP (Python)

### Quick Start
```python
from fastmcp import FastMCP

mcp = FastMCP("My Server")

@mcp.tool()
def calculate(operation: str, a: float, b: float) -> str:
    """Perform a calculation"""
    if operation == "add":
        return str(a + b)
    elif operation == "multiply":
        return str(a * b)
    return "Invalid operation"

if __name__ == "__main__":
    mcp.run()
```

### Advanced FastMCP
```python
from fastmcp import FastMCP
from typing import List, Optional
import httpx

mcp = FastMCP("Weather Server")

@mcp.tool()
async def get_weather(city: str, units: str = "metric") -> str:
    """Get current weather for a city

    Args:
        city: Name of the city
        units: 'metric' or 'imperial' (default: metric)
    """
    async with httpx.AsyncClient() as client:
        response = await client.get(
            f"https://api.weatherapi.com/v1/current.json",
            params={"key": API_KEY, "q": city, "aqi": "no"}
        )
        data = response.json()
        temp = data["current"]["temp_"]
        condition = data["current"]["condition"]["text"]
        return f"Current weather in {city}: {condition}, {temp}°{'C' if units == 'metric' else 'F'}"

@mcp.resource("weather://forecasts/{city}")
async def weather_forecast(city: str) -> str:
    """Get weather forecast resource"""
    # Fetch forecast data
    return f"5-day forecast for {city}: ..."

if __name__ == "__main__":
    mcp.run()
```

## Node/TypeScript MCP

### Quick Start
```typescript
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";

const server = new Server(
  {
    name: "my-server",
    version: "1.0.0",
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

server.setRequestHandler(ListToolsRequestSchema, async () => {
  return {
    tools: [
      {
        name: "calculate",
        description: "Perform a calculation",
        inputSchema: {
          type: "object",
          properties: {
            operation: { type: "string", enum: ["add", "multiply"] },
            a: { type: "number" },
            b: { type: "number" },
          },
          required: ["operation", "a", "b"],
        },
      },
    ],
  };
});

server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;

  if (name === "calculate") {
    const { operation, a, b } = args;
    if (operation === "add") {
      return {
        content: [
          {
            type: "text",
            text: String(a + b),
          },
        ],
      };
    }
  }

  throw new Error("Unknown tool");
});

async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
}

main().catch(console.error);
```

## Patterns and Practices

### Tool Design
1. **Clear Descriptions**: Explain what the tool does
2. **Type Safety**: Define input/output schemas
3. **Error Handling**: Graceful error messages
4. **Async Support**: Use async/await for I/O
5. **Validation**: Validate inputs before processing

### Best Practices
- Use descriptive tool names
- Provide comprehensive descriptions
- Define input schemas with types and constraints
- Handle errors gracefully with clear messages
- Log important operations
- Use environment variables for secrets
- Include examples in tool descriptions
- Implement rate limiting for external APIs

### Error Handling
```python
from fastmcp import FastMCP

mcp = FastMCP("My Server")

@mcp.tool()
def fetch_data(url: str) -> str:
    """Fetch data from URL"""
    try:
        response = httpx.get(url, timeout=10)
        response.raise_for_status()
        return response.text
    except httpx.TimeoutException:
        return "Error: Request timed out"
    except httpx.HTTPStatusError:
        return f"Error: HTTP {response.status_code}"
    except Exception as e:
        return f"Error: {str(e)}"
```

### Resources
```python
@mcp.resource("data://config/{key}")
async def get_config(key: str) -> str:
    """Get configuration value"""
    config = load_config()
    return config.get(key, "Not found")

@mcp.resource("data://reports/{date}")
async def get_report(date: str) -> str:
    """Get report for specific date"""
    report = await fetch_report(date)
    return report.to_json()
```

## Testing

### Unit Tests (Python)
```python
import pytest
from fastmcp import FastMCP

@pytest.mark.asyncio
async def test_calculate_tool():
    mcp = FastMCP("Test Server")

    result = await mcp.call_tool("calculate", {
        "operation": "add",
        "a": 5,
        "b": 3
    })

    assert "8" in result
```

### Integration Tests
```python
async def test_server_connection():
    mcp = FastMCP("Test Server")
    server = await mcp.create_server()

    # Test tool listing
    tools = await server.list_tools()
    assert len(tools) > 0

    # Test tool execution
    result = await server.call_tool("my_tool", {})
    assert result is not None
```

## Deployment

### Docker
```dockerfile
FROM python:3.11-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .

CMD ["python", "server.py"]
```

### Configuration
```yaml
# docker-compose.yml
services:
  mcp-server:
    build: .
    environment:
      - API_KEY=${API_KEY}
      - DATABASE_URL=${DATABASE_URL}
```

## File Patterns

Look for:
- `**/mcp-servers/**/*`
- `**/tools/**/server.py`
- `**/mcp/**/*.{py,ts,js}`
- `**/claude-integration/**/*`

## Keywords

MCP, Model Context Protocol, FastMCP, MCP server, Claude integration, tool development, JSON-RPC, Python MCP, TypeScript MCP, Claude tools, external API integration
