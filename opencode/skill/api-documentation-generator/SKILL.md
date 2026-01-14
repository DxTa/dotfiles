# API Documentation Generator

Generate comprehensive OpenAPI/Swagger documentation from existing APIs with interactive UIs, request/response examples, authentication docs, and multiple export formats.

## When to Use

Use this skill when:
- Creating API documentation from existing code
- Generating OpenAPI/Swagger specifications
- Building interactive API explorers
- Documenting authentication and authorization
- Creating request/response examples
- Exporting documentation in multiple formats
- Integrating documentation into CI/CD
- Maintaining API version documentation

## Key Concepts

### OpenAPI/Swagger Specification
- **OpenAPI 3.0/3.1**: Latest specification standard
- **Swagger 2.0**: Legacy specification
- **Paths**: Endpoints and HTTP methods
- **Components**: Reusable schemas, parameters, responses
- **Security Schemes**: Authentication and authorization

### Documentation Components
- **Endpoints**: URL, HTTP method, description
- **Parameters**: Path, query, header, cookie
- **Request Body**: Schema, content types, examples
- **Responses**: Status codes, schemas, examples
- **Authentication**: API keys, OAuth2, JWT
- **Examples**: Request/response samples
- **Tags**: Grouping endpoints logically

### Output Formats
- **HTML/Markdown**: Human-readable documentation
- **JSON/YAML**: Machine-readable specifications
- **PDF**: Exportable documentation
- **Interactive UIs**: Swagger UI, Redoc, Stoplight

## Common Tools

### Generation
- **Swagger/OpenAPI**: Official specification and tools
- **Redoc**: Beautiful OpenAPI documentation
- **Stoplight Studio**: Visual API design
- **Swagger UI**: Interactive API explorer

### Code-Based Generation
- **JavaScript**: swagger-jsdoc (annotations), swagger-autogen
- **Python**: apispec, connexion
- **Java**: Springdoc OpenAPI
- **Go**: swag
- **.NET**: Swashbuckle

### CLI Tools
- **openapi-generator**: Generate code from specs
- **swagger-codegen**: Multi-language code generation
- **redoc-cli**: Standalone HTML docs

## Patterns and Practices

### Documentation Workflow
1. **Analyze Existing API**: Inspect code, routes, schemas
2. **Generate or Create Spec**: Use code annotations or manual spec
3. **Define Common Components**: Shared schemas, security schemes
4. **Add Examples**: Request/response samples
5. **Document Authentication**: Auth methods, token handling
6. **Generate Documentation**: Create HTML/Markdown
7. **Deploy UI**: Host Swagger UI or Redoc
8. **Integrate with CI/CD**: Auto-generate on changes

### Best Practices
- Use semantic versioning for API versions
- Include detailed descriptions for all endpoints
- Provide multiple examples (success, error, edge cases)
- Document error responses (400, 401, 403, 404, 500)
- Use OpenAPI components for reusable schemas
- Tag endpoints by resource/function
- Include rate limiting information
- Document authentication flows (OAuth2, API keys)
- Maintain changelog for API changes
- Validate OpenAPI specs with linter

### Schema Design
- Use descriptive names for properties
- Add validation rules (min, max, pattern, required)
- Document enum values
- Use proper HTTP verbs (GET, POST, PUT, DELETE)
- Return appropriate status codes
- Include pagination parameters
- Document filtering and sorting

## Examples

### OpenAPI 3.0 Spec (YAML)
```yaml
openapi: 3.0.0
info:
  title: User API
  version: 1.0.0
servers:
  - url: https://api.example.com/v1

paths:
  /users:
    get:
      summary: List users
      tags:
        - users
      parameters:
        - name: limit
          in: query
          schema:
            type: integer
            default: 10
      responses:
        '200':
          description: Successful response
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/User'
    post:
      summary: Create user
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/UserInput'
      responses:
        '201':
          description: User created

components:
  schemas:
    User:
      type: object
      properties:
        id:
          type: integer
        name:
          type: string
        email:
          type: string
          format: email
    UserInput:
      type: object
      required:
        - name
        - email
      properties:
        name:
          type: string
        email:
          type: string
          format: email

security:
  - apiKey: []
```

### JSDoc Annotations (JavaScript)
```javascript
/**
 * @swagger
 * /users/{id}:
 *   get:
 *     summary: Get user by ID
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *     responses:
 *       200:
 *         description: User found
 */
router.get('/users/:id', getUserById);
```

### Python (FastAPI)
```python
from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI()

class User(BaseModel):
    id: int
    name: str
    email: str

@app.get("/users/{user_id}", response_model=User)
async def get_user(user_id: int):
    """
    Get user by ID
    """
    return get_user_from_db(user_id)
```

## Deployment Options

### Swagger UI
```yaml
# docker-compose.yml
services:
  swagger-ui:
    image: swaggerapi/swagger-ui
    volumes:
      - ./openapi.yaml:/usr/share/nginx/html/openapi.yaml
    environment:
      - SWAGGER_JSON=/usr/share/nginx/html/openapi.yaml
    ports:
      - "8080:8080"
```

### Redoc
```bash
redoc-cli bundle openapi.yaml -o docs.html
```

## File Patterns

Look for:
- `**/openapi.yaml`, `**/swagger.yaml`
- `**/openapi.json`, `**/swagger.json`
- `**/docs/api/**/*`
- `**/*.swagger.js`
- `**/routes/**/*` (for code-based generation)

## Keywords

API documentation, OpenAPI, Swagger, REST API documentation, API explorer, request/response examples, authentication docs, Redoc, Swagger UI, API specification, API reference, interactive documentation
