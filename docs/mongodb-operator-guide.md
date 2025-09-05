# MongoDB Community Kubernetes Operator Learning Guide

## Overview
The MongoDB Community Kubernetes Operator automates MongoDB deployment and management in Kubernetes using custom resources and controllers.

## Architecture Components

### 1. Custom Resource Definition (CRD)
- **MongoDBCommunity**: Defines MongoDB cluster specification
- **Purpose**: Extends Kubernetes API with MongoDB-specific resources

### 2. Operator Controller
- **Watches**: MongoDBCommunity resources
- **Manages**: StatefulSets, Services, Secrets, ConfigMaps
- **Reconciles**: Desired state vs actual state

### 3. MongoDB Agent
- **Runs**: Inside each MongoDB pod as sidecar
- **Manages**: MongoDB configuration, replica set setup
- **Monitors**: Health and status

## Key Resources Created

### StatefulSet
- Manages MongoDB pod lifecycle
- Ensures ordered deployment
- Provides stable network identities

### Services
- **Headless Service**: For replica set communication
- **ClusterIP Service**: For application access

### Secrets
- User credentials (SCRAM)
- Keyfile for replica set authentication
- TLS certificates (if enabled)

### ConfigMaps
- MongoDB configuration
- Automation agent configuration

## Learning Exercises

### Exercise 1: Inspect Current Deployment
```bash
# View the MongoDBCommunity resource
kubectl describe mongodbcommunity mongodb-simple

# Check created resources
kubectl get statefulset,service,secret,configmap -l app=mongodb-simple-svc
```

### Exercise 2: Scale the Replica Set
```bash
# Edit the resource to add more members
kubectl patch mongodbcommunity mongodb-simple --type='merge' -p='{"spec":{"members":2}}'

# Watch the scaling process
kubectl get pods -w
```

### Exercise 3: Add a New User
```yaml
# Add to spec.users array
- name: developer
  db: myapp
  passwordSecretRef:
    name: dev-password
  roles:
    - name: readWrite
      db: myapp
```

### Exercise 4: Monitor Operator Logs
```bash
# Watch operator decision making
kubectl logs -f mongodb-kubernetes-operator-xxx

# Check automation agent logs
kubectl logs mongodb-simple-0 -c mongodb-agent -f
```

## Advanced Topics

### 1. Backup and Restore
- Operator doesn't handle backups
- Use external tools like mongodump/mongorestore
- Consider Percona Backup for MongoDB

### 2. Monitoring
- Operator exposes metrics
- Integrate with Prometheus/Grafana
- Monitor replica set health

### 3. Security
- TLS encryption
- RBAC integration
- Network policies

### 4. Troubleshooting
- Check operator logs
- Verify RBAC permissions
- Monitor resource events

## Best Practices

1. **Resource Limits**: Always set CPU/memory limits
2. **Storage**: Use appropriate storage classes
3. **Monitoring**: Implement comprehensive monitoring
4. **Backup**: Regular backup strategy
5. **Security**: Enable authentication and TLS
6. **Updates**: Plan for operator and MongoDB updates

## Common Issues

1. **Pending Pods**: Check storage provisioning
2. **Authentication Errors**: Verify secret configuration
3. **Replica Set Issues**: Check network connectivity
4. **Resource Constraints**: Monitor node resources

## Next Steps

1. Explore different MongoDB configurations
2. Test scaling operations
3. Implement monitoring
4. Practice backup/restore procedures
5. Learn about MongoDB Enterprise Operator
