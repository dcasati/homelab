# AMPR WireGuard Deployment

This deployment requires a Kubernetes Secret containing the WireGuard configuration to be created manually before deploying the application.

## Creating the WireGuard Secret

The AMPR deployment expects a Secret named `ampr-wg-secret` in the `iot-stack` namespace containing the WireGuard configuration file.

### Method 1: Create from file

If you have your `wg0.conf` file ready:

```bash
kubectl create secret generic ampr-wg-secret \
  --from-file=wg0.conf=/path/to/your/wg0.conf \
  --namespace=iot-stack
```

### Method 2: Create from literal

```bash
kubectl create secret generic ampr-wg-secret \
  --from-literal=wg0.conf="$(cat /path/to/your/wg0.conf)" \
  --namespace=iot-stack
```

### Method 3: Using kubectl apply with manifest

Create a file `ampr-secret.yaml` (DO NOT commit this to git):

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: ampr-wg-secret
  namespace: iot-stack
type: Opaque
data:
  wg0.conf: <base64-encoded-wireguard-config>
```

Then apply:
```bash
kubectl apply -f ampr-secret.yaml
```

## Security Notes

- The Secret is mounted with `defaultMode: 0600` (read/write for owner only)
- The volume is mounted as `readOnly: true`
- **NEVER** commit WireGuard configuration files to version control
- The Secret should be created through secure out-of-band processes
- Consider using tools like Sealed Secrets, External Secrets Operator, or HashiCorp Vault for production environments

## Verification

To verify the secret was created correctly:

```bash
kubectl get secrets -n iot-stack ampr-wg-secret
kubectl describe secret -n iot-stack ampr-wg-secret
```

## Sample WireGuard Configuration Structure

Your `wg0.conf` should follow the standard WireGuard format:

```ini
[Interface]
PrivateKey = <private key>
Address = fe80::8363:4ae4:7b5a:36ec/64, 44.31.197.95/24

[Peer]
PublicKey = <public key>
Endpoint = 107.161.208.53:12346
PersistentKeepalive = 20

AllowedIPs = 44.0.0.0/8, fe80::/64
```
