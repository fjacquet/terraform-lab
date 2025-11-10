## Keycloak Best Practices

### Overview

Keycloak is an open-source Identity and Access Management (IAM) solution that provides authentication, authorization, and single sign-on (SSO) capabilities for modern applications and services.

**Core Concepts:**

- **Realms**: Isolated environments for managing users, clients, and configurations
- **Clients**: Applications or services that use Keycloak for authentication
- **Users**: End-users who authenticate through Keycloak
- **Roles**: Permissions assigned to users (realm-level or client-level)
- **Identity Providers**: External authentication sources (SAML, OIDC, social logins)
- **Authentication Flows**: Customizable authentication processes

### Realm Design

**Realm Structure**

```
Production Setup:
├── master realm (admin only)
└── application realms
    ├── production
    ├── staging
    └── development
```

**Best Practices:**

- Never use the `master` realm for application users
- Create separate realms per environment (dev, staging, prod)
- Use descriptive realm names that reflect their purpose
- Configure realm-level settings consistently across environments

**Realm Configuration**

```json
{
  "realm": "my-application",
  "enabled": true,
  "displayName": "My Application",
  "displayNameHtml": "<b>My Application</b>",
  "loginTheme": "custom-theme",
  "accountTheme": "custom-theme",
  "adminTheme": "keycloak",
  "emailTheme": "custom-theme",
  "internationalizationEnabled": true,
  "supportedLocales": ["en", "es", "fr"],
  "defaultLocale": "en",
  "sslRequired": "external",
  "registrationAllowed": false,
  "registrationEmailAsUsername": true,
  "rememberMe": true,
  "verifyEmail": true,
  "loginWithEmailAllowed": true,
  "duplicateEmailsAllowed": false,
  "resetPasswordAllowed": true,
  "editUsernameAllowed": false,
  "bruteForceProtected": true,
  "permanentLockout": false,
  "maxFailureWaitSeconds": 900,
  "minimumQuickLoginWaitSeconds": 60,
  "waitIncrementSeconds": 60,
  "quickLoginCheckMilliSeconds": 1000,
  "maxDeltaTimeSeconds": 43200,
  "failureFactor": 30
}
```

### Client Configuration

**Client Types**

1. **Confidential Clients**: Server-side applications with client secrets
2. **Public Clients**: Browser-based or mobile apps without secrets
3. **Bearer-only Clients**: Backend services that only validate tokens

**Confidential Client Setup**

```json
{
  "clientId": "my-backend-service",
  "name": "My Backend Service",
  "description": "Backend API service",
  "enabled": true,
  "clientAuthenticatorType": "client-secret",
  "secret": "**********",
  "redirectUris": [
    "https://api.example.com/*",
    "https://api.example.com/callback"
  ],
  "webOrigins": [
    "https://app.example.com"
  ],
  "protocol": "openid-connect",
  "publicClient": false,
  "bearerOnly": false,
  "standardFlowEnabled": true,
  "implicitFlowEnabled": false,
  "directAccessGrantsEnabled": false,
  "serviceAccountsEnabled": true,
  "authorizationServicesEnabled": true,
  "fullScopeAllowed": false,
  "consentRequired": false,
  "attributes": {
    "access.token.lifespan": "300",
    "client.session.idle.timeout": "1800",
    "client.session.max.lifespan": "36000"
  }
}
```

**Public Client Setup (SPA)**

```json
{
  "clientId": "my-spa-app",
  "name": "My Single Page Application",
  "enabled": true,
  "publicClient": true,
  "redirectUris": [
    "https://app.example.com/*",
    "http://localhost:3000/*"
  ],
  "webOrigins": [
    "https://app.example.com",
    "http://localhost:3000"
  ],
  "protocol": "openid-connect",
  "standardFlowEnabled": true,
  "implicitFlowEnabled": false,
  "directAccessGrantsEnabled": false,
  "attributes": {
    "pkce.code.challenge.method": "S256"
  }
}
```

**Client Best Practices:**

- Always use PKCE for public clients
- Disable implicit flow (use authorization code flow)
- Limit redirect URIs to specific paths
- Use specific web origins for CORS
- Enable service accounts for machine-to-machine communication
- Set appropriate token lifespans
- Disable direct access grants unless absolutely necessary

### User Management

**User Creation**

```json
{
  "username": "john.doe",
  "email": "john.doe@example.com",
  "firstName": "John",
  "lastName": "Doe",
  "enabled": true,
  "emailVerified": true,
  "attributes": {
    "department": ["Engineering"],
    "employee_id": ["12345"]
  },
  "requiredActions": [],
  "credentials": [
    {
      "type": "password",
      "value": "temporary-password",
      "temporary": true
    }
  ]
}
```

**User Attributes**

- Use attributes for custom user metadata
- Keep attribute names consistent across realms
- Use arrays for multi-valued attributes
- Avoid storing sensitive data in attributes

**Required Actions**

```
- VERIFY_EMAIL: Force email verification
- UPDATE_PASSWORD: Force password change
- CONFIGURE_TOTP: Require MFA setup
- UPDATE_PROFILE: Update user profile
- TERMS_AND_CONDITIONS: Accept terms
```

### Role-Based Access Control (RBAC)

**Realm Roles vs Client Roles**

- **Realm Roles**: Global roles across all clients in the realm
- **Client Roles**: Specific to individual clients

**Role Hierarchy**

```
Realm Roles:
├── admin (composite)
│   ├── user-manager
│   └── client-manager
├── user
└── guest

Client Roles (my-app):
├── app-admin
├── app-user
└── app-viewer
```

**Composite Roles**

```json
{
  "name": "admin",
  "composite": true,
  "composites": {
    "realm": ["user-manager", "client-manager"],
    "client": {
      "my-app": ["app-admin"]
    }
  }
}
```

**Role Mapping Best Practices:**

- Use composite roles to group permissions
- Assign roles at the group level when possible
- Use client roles for application-specific permissions
- Use realm roles for cross-application permissions
- Implement least privilege principle

### Groups and Group Hierarchy

**Group Structure**

```
Organization:
├── Engineering
│   ├── Backend
│   ├── Frontend
│   └── DevOps
├── Sales
└── Support
```

**Group Configuration**

```json
{
  "name": "Engineering",
  "path": "/Engineering",
  "attributes": {
    "cost_center": ["ENG-001"],
    "location": ["San Francisco"]
  },
  "realmRoles": ["user"],
  "clientRoles": {
    "my-app": ["app-user"]
  },
  "subGroups": [
    {
      "name": "Backend",
      "path": "/Engineering/Backend",
      "realmRoles": ["developer"],
      "clientRoles": {
        "my-app": ["backend-developer"]
      }
    }
  ]
}
```

**Group Best Practices:**

- Use groups to organize users by department, team, or function
- Assign roles to groups instead of individual users
- Use group attributes for organizational metadata
- Leverage group hierarchy for inherited permissions

### Authentication Flows

**Standard Flows**

1. **Browser Flow**: Web application login
2. **Direct Grant Flow**: Username/password authentication (use sparingly)
3. **Client Credentials Flow**: Service-to-service authentication
4. **Device Flow**: IoT and limited-input devices

**Custom Authentication Flow Example**

```
Custom Browser Flow:
├── Cookie
├── Kerberos (optional)
├── Identity Provider Redirector
└── Forms
    ├── Username Password Form
    └── OTP Form (conditional)
```

**Multi-Factor Authentication (MFA)**

```json
{
  "requiredActions": ["CONFIGURE_TOTP"],
  "otpPolicyType": "totp",
  "otpPolicyAlgorithm": "HmacSHA1",
  "otpPolicyDigits": 6,
  "otpPolicyLookAheadWindow": 1,
  "otpPolicyPeriod": 30
}
```

**Authentication Best Practices:**

- Enable MFA for administrative accounts
- Use conditional MFA based on risk factors
- Implement account lockout policies
- Configure password policies appropriately
- Use remember me with caution

### Token Configuration

**Token Lifespans**

```json
{
  "accessTokenLifespan": 300,
  "accessTokenLifespanForImplicitFlow": 900,
  "ssoSessionIdleTimeout": 1800,
  "ssoSessionMaxLifespan": 36000,
  "offlineSessionIdleTimeout": 2592000,
  "offlineSessionMaxLifespan": 5184000,
  "accessCodeLifespan": 60,
  "accessCodeLifespanUserAction": 300,
  "accessCodeLifespanLogin": 1800,
  "actionTokenGeneratedByAdminLifespan": 43200,
  "actionTokenGeneratedByUserLifespan": 300
}
```

**Token Claims**

```json
{
  "protocolMappers": [
    {
      "name": "email",
      "protocol": "openid-connect",
      "protocolMapper": "oidc-usermodel-property-mapper",
      "consentRequired": false,
      "config": {
        "userinfo.token.claim": "true",
        "user.attribute": "email",
        "id.token.claim": "true",
        "access.token.claim": "true",
        "claim.name": "email",
        "jsonType.label": "String"
      }
    },
    {
      "name": "roles",
      "protocol": "openid-connect",
      "protocolMapper": "oidc-usermodel-realm-role-mapper",
      "consentRequired": false,
      "config": {
        "multivalued": "true",
        "userinfo.token.claim": "true",
        "id.token.claim": "true",
        "access.token.claim": "true",
        "claim.name": "roles",
        "jsonType.label": "String"
      }
    }
  ]
}
```

**Token Best Practices:**

- Keep access token lifespans short (5-15 minutes)
- Use refresh tokens for long-lived sessions
- Include only necessary claims in tokens
- Use audience claim to restrict token usage
- Implement token revocation for logout

### Identity Brokering

**OIDC Identity Provider**

```json
{
  "alias": "google",
  "displayName": "Google",
  "providerId": "google",
  "enabled": true,
  "trustEmail": true,
  "storeToken": false,
  "addReadTokenRoleOnCreate": false,
  "authenticateByDefault": false,
  "linkOnly": false,
  "firstBrokerLoginFlowAlias": "first broker login",
  "config": {
    "clientId": "google-client-id",
    "clientSecret": "google-client-secret",
    "defaultScope": "openid profile email",
    "syncMode": "IMPORT"
  }
}
```

**SAML Identity Provider**

```json
{
  "alias": "corporate-saml",
  "displayName": "Corporate SSO",
  "providerId": "saml",
  "enabled": true,
  "config": {
    "singleSignOnServiceUrl": "https://idp.example.com/saml/sso",
    "singleLogoutServiceUrl": "https://idp.example.com/saml/logout",
    "nameIDPolicyFormat": "urn:oasis:names:tc:SAML:2.0:nameid-format:persistent",
    "principalType": "SUBJECT",
    "signatureAlgorithm": "RSA_SHA256",
    "xmlSigKeyInfoKeyNameTransformer": "KEY_ID",
    "wantAuthnRequestsSigned": "true",
    "validateSignature": "true",
    "signingCertificate": "-----BEGIN CERTIFICATE-----\n...\n-----END CERTIFICATE-----"
  }
}
```

**Identity Brokering Best Practices:**

- Use identity brokering for enterprise SSO integration
- Configure first broker login flow for account linking
- Map external claims to Keycloak user attributes
- Implement account linking strategies
- Store tokens only when necessary

### Client Scopes

**Default Client Scopes**

```
- openid: Required for OIDC
- profile: User profile information
- email: Email address
- roles: User roles
- web-origins: CORS origins
```

**Custom Client Scope**

```json
{
  "name": "custom-claims",
  "description": "Custom application claims",
  "protocol": "openid-connect",
  "attributes": {
    "include.in.token.scope": "true",
    "display.on.consent.screen": "true",
    "consent.screen.text": "Custom application data"
  },
  "protocolMappers": [
    {
      "name": "department",
      "protocol": "openid-connect",
      "protocolMapper": "oidc-usermodel-attribute-mapper",
      "config": {
        "user.attribute": "department",
        "claim.name": "department",
        "jsonType.label": "String",
        "id.token.claim": "true",
        "access.token.claim": "true",
        "userinfo.token.claim": "true"
      }
    }
  ]
}
```

**Client Scope Best Practices:**

- Use client scopes to organize protocol mappers
- Create reusable scopes for common claims
- Use optional scopes for sensitive data
- Implement consent for optional scopes
- Keep token size minimal

### Security Best Practices

**Password Policies**

```json
{
  "passwordPolicy": "length(12) and digits(1) and lowerCase(1) and upperCase(1) and specialChars(1) and notUsername and notEmail and passwordHistory(5) and forceExpiredPasswordChange(365)"
}
```

**Brute Force Protection**

```json
{
  "bruteForceProtected": true,
  "permanentLockout": false,
  "maxFailureWaitSeconds": 900,
  "minimumQuickLoginWaitSeconds": 60,
  "waitIncrementSeconds": 60,
  "quickLoginCheckMilliSeconds": 1000,
  "maxDeltaTimeSeconds": 43200,
  "failureFactor": 30
}
```

**SSL/TLS Configuration**

```json
{
  "sslRequired": "external"
}
```

Options:

- `all`: Require SSL for all connections
- `external`: Require SSL for external requests only
- `none`: No SSL required (development only)

**Security Headers**

```
X-Frame-Options: SAMEORIGIN
X-Content-Type-Options: nosniff
X-XSS-Protection: 1; mode=block
Strict-Transport-Security: max-age=31536000; includeSubDomains
Content-Security-Policy: frame-ancestors 'self'
```

**Security Checklist:**

- [ ] Enable SSL/TLS in production
- [ ] Configure strong password policies
- [ ] Enable brute force protection
- [ ] Implement MFA for admin accounts
- [ ] Use client secrets for confidential clients
- [ ] Rotate client secrets regularly
- [ ] Audit admin actions
- [ ] Limit admin access
- [ ] Use service accounts for automation
- [ ] Implement token revocation
- [ ] Configure CORS properly
- [ ] Validate redirect URIs strictly

### Admin REST API Usage

**Authentication**

```bash
# Get admin access token
curl -X POST "https://keycloak.example.com/realms/master/protocol/openid-connect/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=admin" \
  -d "password=admin-password" \
  -d "grant_type=password" \
  -d "client_id=admin-cli"
```

**Create User**

```bash
curl -X POST "https://keycloak.example.com/admin/realms/my-realm/users" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "john.doe",
    "email": "john.doe@example.com",
    "firstName": "John",
    "lastName": "Doe",
    "enabled": true,
    "emailVerified": true,
    "credentials": [{
      "type": "password",
      "value": "password123",
      "temporary": true
    }]
  }'
```

**Assign Role to User**

```bash
# Get role representation
ROLE=$(curl -X GET "https://keycloak.example.com/admin/realms/my-realm/roles/user" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}")

# Assign role
curl -X POST "https://keycloak.example.com/admin/realms/my-realm/users/${USER_ID}/role-mappings/realm" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d "[${ROLE}]"
```

**API Best Practices:**

- Use service accounts for API access
- Implement rate limiting
- Cache access tokens (respect expiration)
- Handle errors gracefully
- Use batch operations when possible
- Implement retry logic with exponential backoff

### High Availability and Clustering

**Database Configuration**

```
Supported Databases:
- PostgreSQL (recommended)
- MySQL/MariaDB
- Oracle
- Microsoft SQL Server
```

**Clustering Setup**

```xml
<!-- standalone-ha.xml -->
<subsystem xmlns="urn:jboss:domain:infinispan:14.0">
    <cache-container name="keycloak">
        <transport lock-timeout="60000"/>
        <distributed-cache name="sessions" owners="2"/>
        <distributed-cache name="authenticationSessions" owners="2"/>
        <distributed-cache name="offlineSessions" owners="2"/>
        <distributed-cache name="clientSessions" owners="2"/>
        <distributed-cache name="offlineClientSessions" owners="2"/>
        <distributed-cache name="loginFailures" owners="2"/>
        <distributed-cache name="actionTokens" owners="2"/>
    </cache-container>
</subsystem>
```

**Load Balancer Configuration**

```nginx
upstream keycloak {
    least_conn;
    server keycloak1:8080;
    server keycloak2:8080;
    server keycloak3:8080;
}

server {
    listen 443 ssl http2;
    server_name auth.example.com;

    ssl_certificate /etc/ssl/certs/auth.example.com.crt;
    ssl_certificate_key /etc/ssl/private/auth.example.com.key;

    location / {
        proxy_pass http://keycloak;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Port $server_port;
        
        proxy_buffer_size 128k;
        proxy_buffers 4 256k;
        proxy_busy_buffers_size 256k;
    }
}
```

**HA Best Practices:**

- Use external database (not H2)
- Configure database connection pooling
- Enable sticky sessions on load balancer
- Use distributed caching
- Monitor cache hit rates
- Implement health checks
- Use multiple availability zones

### Monitoring and Observability

**Metrics to Monitor**

```
- Active sessions
- Login success/failure rates
- Token generation rate
- Database connection pool usage
- Cache hit/miss rates
- Response times
- Error rates
- JVM memory usage
- CPU usage
```

**Health Check Endpoint**

```bash
curl https://keycloak.example.com/health
curl https://keycloak.example.com/health/ready
curl https://keycloak.example.com/health/live
```

**Logging Configuration**

```xml
<!-- standalone.xml -->
<subsystem xmlns="urn:jboss:domain:logging:8.0">
    <logger category="org.keycloak">
        <level name="INFO"/>
    </logger>
    <logger category="org.keycloak.events">
        <level name="DEBUG"/>
    </logger>
</subsystem>
```

**Event Listeners**

```json
{
  "eventsEnabled": true,
  "eventsExpiration": 259200,
  "eventsListeners": ["jboss-logging"],
  "enabledEventTypes": [
    "LOGIN",
    "LOGIN_ERROR",
    "LOGOUT",
    "REGISTER",
    "UPDATE_PASSWORD",
    "UPDATE_PROFILE"
  ],
  "adminEventsEnabled": true,
  "adminEventsDetailsEnabled": true
}
```

### Backup and Disaster Recovery

**Export Realm Configuration**

```bash
# Export single realm
/opt/keycloak/bin/kc.sh export \
  --dir /tmp/keycloak-export \
  --realm my-realm \
  --users realm_file

# Export all realms
/opt/keycloak/bin/kc.sh export \
  --dir /tmp/keycloak-export \
  --users realm_file
```

**Database Backup**

```bash
# PostgreSQL backup
pg_dump -h localhost -U keycloak keycloak_db > keycloak_backup.sql

# Restore
psql -h localhost -U keycloak keycloak_db < keycloak_backup.sql
```

**Backup Best Practices:**

- Automate regular backups
- Test restore procedures
- Back up database and realm configurations
- Store backups securely and off-site
- Document recovery procedures
- Include secrets and certificates in backup plan

### Performance Optimization

**JVM Tuning**

```bash
# Set JVM options
export JAVA_OPTS="-Xms2g -Xmx4g \
  -XX:MetaspaceSize=256m \
  -XX:MaxMetaspaceSize=512m \
  -XX:+UseG1GC \
  -XX:MaxGCPauseMillis=200 \
  -Djava.net.preferIPv4Stack=true"
```

**Database Optimization**

```sql
-- Create indexes for performance
CREATE INDEX idx_user_email ON user_entity(email);
CREATE INDEX idx_user_username ON user_entity(username);
CREATE INDEX idx_user_realm ON user_entity(realm_id);
```

**Caching Strategy**

- Enable realm cache
- Enable user cache
- Configure cache sizes appropriately
- Use distributed cache in clustered environments
- Monitor cache hit rates

**Performance Best Practices:**

- Use connection pooling
- Optimize database queries
- Enable caching
- Use CDN for static assets
- Implement rate limiting
- Monitor and tune JVM
- Use async processing where possible

### Migration and Upgrades

**Pre-Upgrade Checklist:**

- [ ] Review release notes
- [ ] Back up database
- [ ] Export realm configurations
- [ ] Test upgrade in non-production environment
- [ ] Document custom extensions
- [ ] Check theme compatibility
- [ ] Verify client library compatibility

**Upgrade Process**

```bash
# 1. Stop Keycloak
systemctl stop keycloak

# 2. Backup database
pg_dump keycloak_db > backup_before_upgrade.sql

# 3. Export realms
/opt/keycloak/bin/kc.sh export --dir /backup/realms

# 4. Install new version
# (Follow official upgrade guide)

# 5. Start Keycloak
systemctl start keycloak

# 6. Verify functionality
curl https://keycloak.example.com/health
```

### Troubleshooting

**Common Issues**

1. **Token Validation Failures**
   - Check token expiration
   - Verify issuer claim
   - Validate audience claim
   - Check clock skew

2. **CORS Errors**
   - Configure web origins in client
   - Check redirect URIs
   - Verify protocol (HTTP vs HTTPS)

3. **Session Issues**
   - Check session timeouts
   - Verify cookie settings
   - Check load balancer sticky sessions

4. **Performance Issues**
   - Monitor database connections
   - Check cache hit rates
   - Review JVM memory usage
   - Analyze slow queries

**Debug Logging**

```bash
# Enable debug logging
/opt/keycloak/bin/kc.sh start \
  --log-level=DEBUG \
  --log-console-level=DEBUG
```

### Integration Examples

**Spring Boot Integration**

```yaml
# application.yml
spring:
  security:
    oauth2:
      client:
        registration:
          keycloak:
            client-id: my-spring-app
            client-secret: ${KEYCLOAK_CLIENT_SECRET}
            scope: openid,profile,email
            authorization-grant-type: authorization_code
            redirect-uri: "{baseUrl}/login/oauth2/code/{registrationId}"
        provider:
          keycloak:
            issuer-uri: https://keycloak.example.com/realms/my-realm
            user-name-attribute: preferred_username
```

**Node.js Integration**

```javascript
const Keycloak = require('keycloak-connect');
const session = require('express-session');

const memoryStore = new session.MemoryStore();
const keycloak = new Keycloak({
  store: memoryStore
}, {
  realm: 'my-realm',
  'auth-server-url': 'https://keycloak.example.com',
  'ssl-required': 'external',
  resource: 'my-node-app',
  'confidential-port': 0,
  credentials: {
    secret: process.env.KEYCLOAK_CLIENT_SECRET
  }
});

app.use(session({
  secret: 'session-secret',
  resave: false,
  saveUninitialized: true,
  store: memoryStore
}));

app.use(keycloak.middleware());

// Protect routes
app.get('/protected', keycloak.protect(), (req, res) => {
  res.json({ message: 'Protected resource' });
});

// Role-based protection
app.get('/admin', keycloak.protect('realm:admin'), (req, res) => {
  res.json({ message: 'Admin resource' });
});
```

**Python Integration**

```python
from keycloak import KeycloakOpenID

# Configure client
keycloak_openid = KeycloakOpenID(
    server_url="https://keycloak.example.com",
    client_id="my-python-app",
    realm_name="my-realm",
    client_secret_key="client-secret"
)

# Get token
token = keycloak_openid.token(
    username="user@example.com",
    password="password"
)

# Introspect token
token_info = keycloak_openid.introspect(token['access_token'])

# Decode token
decoded_token = keycloak_openid.decode_token(
    token['access_token'],
    validate=True
)

# Check roles
if 'admin' in decoded_token.get('realm_access', {}).get('roles', []):
    print("User is admin")
```
