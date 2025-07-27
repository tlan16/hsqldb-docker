# HSQLDB Docker Container with Health Check

This project provides a Docker container for HSQLDB with a comprehensive health check system.

## Features

- **HSQLDB Server**: Runs HSQLDB 2.7.1 on port 9001
- **Health Check**: Multi-layered health checking including:
  - Port connectivity test
  - Database connection test
  - SQL query execution test
- **Security**: Runs as non-root user
- **Persistence**: Data is stored in a Docker volume

## Quick Start

### Using Docker Compose (Recommended)

```bash
# Build and start the container
docker-compose up -d

# Check health status
docker-compose ps

# View logs
docker-compose logs -f hsqldb

# Stop the container
docker-compose down
```

### Using Docker directly

```bash
# Build the image
docker build -t hsqldb-server .

# Run the container
docker run -d \
  --name hsqldb-server \
  -p 9001:9001 \
  -v hsqldb_data:/opt/hsqldb/data \
  hsqldb-server

# Check health status
docker ps

# View health check logs
docker logs hsqldb-server
```

## Health Check Details

The health check performs the following tests:

1. **Port Check**: Verifies that port 9001 is accessible
2. **Connection Test**: Attempts to establish a JDBC connection
3. **Query Test**: Executes a simple SQL query to ensure the database is responsive

### Health Check Configuration

- **Interval**: 30 seconds between checks
- **Timeout**: 10 seconds per check
- **Retries**: 3 failed attempts before marking as unhealthy
- **Start Period**: 40 seconds grace period during startup

## Connecting to HSQLDB

### Connection Details

- **Host**: localhost (or container IP)
- **Port**: 9001
- **Database**: mydb
- **Username**: SA
- **Password**: (empty)
- **JDBC URL**: `jdbc:hsqldb:hsql://localhost:9001/mydb`

### Example Connection (Java)

```java
import java.sql.*;

public class HSQLDBExample {
    public static void main(String[] args) {
        String url = "jdbc:hsqldb:hsql://localhost:9001/mydb";
        String user = "SA";
        String password = "";
        
        try {
            Connection conn = DriverManager.getConnection(url, user, password);
            System.out.println("Connected to HSQLDB!");
            conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
```

## Monitoring

### Check Container Health

```bash
# View health status
docker inspect hsqldb-server | grep -A 10 '"Health"'

# Or with docker-compose
docker-compose ps
```

### Manual Health Check

```bash
# Run health check manually
docker exec hsqldb-server /usr/local/bin/healthcheck.sh
```

## Troubleshooting

### Common Issues

1. **Container fails to start**:
   - Check if port 9001 is already in use
   - Verify Docker has sufficient resources

2. **Health check fails**:
   - Check container logs: `docker logs hsqldb-server`
   - Verify HSQLDB is starting properly
   - Ensure no firewall is blocking port 9001

3. **Connection refused**:
   - Wait for the start period (40 seconds) to complete
   - Check if the container is healthy: `docker ps`

### Logs

```bash
# View all logs
docker logs hsqldb-server

# Follow logs in real-time
docker logs -f hsqldb-server

# View only health check logs
docker logs hsqldb-server 2>&1 | grep HEALTHCHECK
```

## Customization

### Environment Variables

You can customize the setup by modifying the `docker-compose.yml` file:

```yaml
environment:
  - JAVA_OPTS=-Xmx1g  # Increase memory
```

### Database Configuration

To change database settings, modify the CMD in the Dockerfile:

```dockerfile
CMD ["java", "-cp", "/opt/hsqldb.jar", "org.hsqldb.server.Server", \
     "--database.0", "file:data/mydb", "--dbname.0", "mydb", \
     "--port", "9001", "--silent", "false", "--trace", "true"]
```

## Security Notes

- The container runs as a non-root user (`hsqldb`)
- Default HSQLDB configuration uses SA user with no password
- For production use, consider:
  - Setting up proper authentication
  - Using encrypted connections
  - Restricting network access

## File Structure

```
.
├── Dockerfile              # Main Docker image definition
├── docker-compose.yml      # Docker Compose configuration
├── healthcheck.sh          # Health check script
└── README.md              # This file
```
