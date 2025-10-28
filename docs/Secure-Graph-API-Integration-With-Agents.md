# Secure Graph API Integration with Foundry Agents

## Overview

This document outlines the recommended architecture for integrating Microsoft Graph API operations within Foundry Agent workflows while maintaining security best practices and API-First principles.

## Architecture Pattern

### Flow Diagram
```
Frontend App 
    ↓
Your Backend API (Token Owner)
    ↓
Foundry Agent
    ↓
Tool
    ↓
Your Backend API (Graph Proxy)
    ↓
Microsoft Graph API
```

### Key Principles

1. **Token Custody**: Your backend API owns and manages all Graph API tokens
2. **API-First**: All external API calls flow through your backend endpoints
3. **Agent Autonomy**: Foundry Agents can orchestrate Graph operations without handling sensitive credentials
4. **Security Isolation**: Tokens never leave your controlled environment

## Implementation Details

### 1. Backend API Design

#### Token Management Layer
- Implement secure token storage and refresh logic
- Handle user authentication and Graph API token acquisition
- Manage token lifecycle (expiration, renewal, revocation)

#### Graph API Proxy Endpoints
Create dedicated endpoints that wrap Graph API operations:

```javascript
// Example endpoints
POST /api/graph/users/me/drive/files
POST /api/graph/users/me/calendar/events  
POST /api/graph/teams/{id}/channels
POST /api/graph/users/me/messages
```

#### Authentication Middleware
- Validate incoming requests from Foundry tools
- Ensure proper authorization for Graph operations
- Log all Graph API interactions for audit trails

### 2. Foundry Agent Configuration

#### Tool Setup
Configure tools to call your backend endpoints instead of Graph API directly:

```yaml
# Tool Configuration Example
tool_name: "SharePointTool"
endpoint: "https://yourapi.com/api/graph/sharepoint"
method: "POST"
headers:
  - "Authorization: Bearer {foundry_tool_token}"
  - "Content-Type: application/json"
```

#### Workflow Design
- Agent orchestrates the business logic
- Tools make HTTP calls to your backend API
- No Graph API tokens or credentials in agent environment

### 3. Security Implementation

#### Token Types and Lifetimes

| Token Type | Lifetime | Storage | Purpose |
|------------|----------|---------|---------|
| Frontend Session | 15-30 min | Memory | API calls to your backend |
| Refresh Token | 4 hours | HttpOnly Cookie | Session persistence |
| Graph Access Token | 1 hour | Backend secure storage | Graph API operations |
| Graph Refresh Token | 90 days | Backend secure storage | Token renewal |

#### Security Controls
- **Encryption**: All tokens encrypted at rest
- **HTTPS Only**: All communication over TLS
- **Token Validation**: Verify token integrity and expiration
- **Scope Limitation**: Request minimal Graph API permissions
- **Audit Logging**: Log all token operations and Graph API calls

### 4. Error Handling

#### Token Expiration
```javascript
// Backend API - Graph proxy endpoint
async function callGraphAPI(endpoint, userToken) {
  try {
    return await graphAPI.call(endpoint, userToken);
  } catch (error) {
    if (error.status === 401) {
      // Token expired - refresh and retry
      const newToken = await refreshUserToken(userToken);
      return await graphAPI.call(endpoint, newToken);
    }
    throw error;
  }
}
```

#### Rate Limiting
- Implement circuit breaker patterns
- Handle 429 (Too Many Requests) responses
- Queue requests during rate limit periods

#### Failure Recovery
- Graceful degradation when Graph API is unavailable
- Retry logic with exponential backoff
- Clear error messages back to frontend

## Benefits

### Security
- ✅ Tokens never exposed to agent environment
- ✅ Centralized token management and rotation
- ✅ Complete audit trail of Graph API usage
- ✅ Ability to revoke access immediately

### Architecture
- ✅ Maintains API-First principles
- ✅ Clean separation of concerns
- ✅ Agents focus on orchestration, not integration
- ✅ Scalable and maintainable design

### Operations
- ✅ Centralized monitoring and logging
- ✅ Consistent error handling across all Graph operations
- ✅ Rate limiting and throttling control
- ✅ Easy to implement caching strategies

## Trade-offs

### Performance
- ❌ Additional network hop through backend API
- ❌ Slight increase in latency for Graph operations

### Complexity
- ❌ Need to create proxy endpoints for each Graph operation
- ❌ More complex backend API surface area
- ❌ Additional error handling scenarios

### Development
- ❌ More backend endpoints to develop and maintain
- ❌ Need to map Graph API responses through proxy layer

## Implementation Checklist

### Backend API Development
- [ ] Implement OAuth 2.0 flow for Graph API token acquisition
- [ ] Create secure token storage with encryption
- [ ] Build Graph API proxy endpoints
- [ ] Implement token refresh logic
- [ ] Add comprehensive logging and monitoring
- [ ] Create authentication middleware for tool requests

### Foundry Agent Configuration  
- [ ] Configure tools to call backend endpoints
- [ ] Set up proper authentication for tool requests
- [ ] Test agent workflows end-to-end
- [ ] Implement error handling in agent logic

### Security Hardening
- [ ] Enable HTTPS for all communications
- [ ] Implement proper CORS policies
- [ ] Set up token encryption at rest
- [ ] Configure audit logging
- [ ] Test token refresh scenarios
- [ ] Validate minimal privilege access

### Monitoring & Operations
- [ ] Set up health checks for Graph API connectivity
- [ ] Implement alerting for token expiration
- [ ] Monitor rate limiting and throttling
- [ ] Create dashboards for Graph API usage
- [ ] Test disaster recovery scenarios

## Architectural Conflict: API-First vs Agent Autonomy

### The Fundamental Tension

This use case highlights a **fundamental architectural conflict** between two well-established patterns:

#### API-First Architecture Principles
- **Centralized Control**: All external API calls flow through your backend
- **Security Boundary**: Backend owns all credentials and tokens
- **Consistent Interface**: Frontend only talks to your API endpoints
- **Observability**: Centralized logging, monitoring, and rate limiting
- **Data Governance**: Backend controls what data flows in/out

#### Agent Architecture Principles  
- **Autonomous Decision Making**: Agents choose which tools to use dynamically
- **Direct Tool Integration**: Tools call external APIs directly for efficiency
- **Runtime Flexibility**: Agents adapt their API calls based on context
- **Reduced Latency**: Direct connections eliminate proxy overhead
- **Tool Reusability**: Same tools work across different agent workflows

### Where Traditional Patterns Break Down

#### 1. **Dynamic Tool Selection**
```
Traditional: Frontend → Backend API → Known External API
Agent Pattern: Frontend → Backend API → Agent → [Unknown Tool Selection] → Multiple External APIs
```

In agent architectures, you don't know **which external APIs** will be called until runtime. This breaks the traditional pattern where your backend pre-defines all external integrations.

#### 2. **Token Custody Chain**
```
Traditional: Your Backend (Token Owner) → External API
Agent Pattern: Your Backend → Agent Platform → Tool → External API
```

The **custody chain** is broken because tokens must traverse through systems you don't control (Foundry, tools). This violates the principle that sensitive credentials should never leave your security boundary.

#### 3. **Tool Autonomy vs Security Control**
```
Traditional: You control every API call and can implement security policies
Agent Pattern: Tools need autonomy to make API calls, but you lose granular control
```

**The core conflict**: Tools need enough autonomy to be useful, but autonomy inherently conflicts with centralized security control.

#### 4. **Observability Gaps**
```
Traditional: All API calls visible in your backend logs
Agent Pattern: API calls happen in tool execution environment outside your observability
```

When tools call external APIs directly, you lose visibility into:
- What APIs were called and when
- What data was accessed or modified  
- Rate limiting and error patterns
- Security events and audit trails

### Why This Use Case is Particularly Problematic

#### Microsoft Graph API Characteristics
- **Highly Sensitive**: Access to emails, files, calendar, user data
- **User-Scoped Permissions**: Many operations require user-delegated tokens
- **Short Token Lifetimes**: 1-hour expiration requires active refresh management
- **Complex Permission Model**: Delegated vs Application permissions with different security implications

#### Agent Platform Limitations
- **Token Persistence**: Agents may need to store tokens for workflow duration
- **Multi-User Context**: Single agent instance may handle multiple users' tokens
- **Asynchronous Operations**: Long-running workflows outlive token lifetimes
- **Security Boundaries**: Agent platforms weren't designed for sensitive credential management

### The Architectural Decision Point

Organizations must choose between:

#### Option A: Maintain API-First (Recommended)
- **Accept**: Additional complexity and latency
- **Gain**: Security, observability, and control
- **Pattern**: Backend API becomes Graph API proxy

#### Option B: Agent Autonomy
- **Accept**: Security risks and observability gaps  
- **Gain**: Simpler agent development and lower latency
- **Pattern**: Direct tool → Graph API integration

#### Option C: Hybrid Compromise
- **Low-risk operations**: Agent autonomy (application permissions)
- **High-risk operations**: API-First pattern (user permissions)
- **Complexity**: Need to maintain both patterns

### Industry Evolution

This conflict represents a broader industry challenge:

**Traditional Enterprise Architecture** was designed for:
- Predictable integration patterns
- Centralized security models
- Human-driven workflows
- Static API consumption

**Modern AI/Agent Architecture** requires:
- Dynamic integration discovery
- Distributed autonomous systems
- AI-driven decision making
- Runtime API composition

### Lessons Learned

1. **Security vs Autonomy Trade-off**: There's no "perfect" solution, only informed trade-offs
2. **Platform Maturity Gap**: Agent platforms are evolving faster than enterprise security patterns
3. **Token Management Complexity**: User-scoped tokens are fundamentally incompatible with autonomous systems
4. **Architectural Debt**: Early agent implementations may create security debt that's expensive to fix later

### Recommendation

For **Microsoft Graph API integrations specifically**, we recommend **maintaining API-First principles** despite the added complexity. The security implications of user-scoped tokens are too significant to compromise on.

For **other external APIs** with less sensitive data or application-scoped permissions, organizations may choose different trade-offs based on their risk tolerance.

## Alternative Patterns

### Event-Driven Pattern (For Administrative Operations)
For operations that don't require user-specific permissions:

```
Frontend → Backend API → Foundry Agent → Event Queue → Background Service → Graph API
```

- Use application permissions instead of user tokens
- Better for long-running or batch operations
- Eliminates user token management complexity

### Hybrid Approach
Combine both patterns based on operation type:
- **User-specific operations**: Use the proxy pattern described above
- **Administrative operations**: Use event-driven pattern with service principal

## Best Practices

1. **Keep It Simple**: Start with essential Graph operations only
2. **Monitor Everything**: Comprehensive logging and alerting
3. **Plan for Scale**: Consider caching and rate limiting from day one
4. **Security First**: Regular security reviews and token rotation
5. **Test Thoroughly**: Comprehensive testing of token expiration scenarios

## Conclusion

This architecture provides a secure, maintainable approach to integrating Graph API operations within Foundry Agent workflows. While it introduces some complexity, it maintains proper security boundaries and API-First principles while enabling powerful agent-driven automation.

The key insight is that **your backend API becomes the secure gateway** between autonomous agents and Microsoft Graph API, ensuring tokens remain under your control while still enabling rich integration capabilities.
