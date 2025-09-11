# Exposing internal services with Tailscale Funnel on Kubernetes

Add these two tags to the Tailscale ACL (on the Admin Portal): `tag:k8s-operator` and `tag:k8s`

```json
	"tagOwners": {
		"tag:k8s-operator": ["autogroup:admin", "diego.casat@gmail.com"],
		"tag:k8s":          ["autogroup:admin", "diego.casat@gmail.com"],
	},
```

Add these tags to the `nodeAttrs`:

```json
	"nodeAttrs": [
		{
			// Funnel policy, which lets tailnet members control Funnel
			// for their own devices.
			// Learn more at https://tailscale.com/kb/1223/tailscale-funnel/
			"target": ["autogroup:member"],
			"attr":   ["funnel"],
		},
		{
			"target": ["tag:k8s"], // tag that Tailscale Operator uses to tag proxies; defaults to 'tag:k8s'
			"attr":   ["funnel"],
		},
		{
			"target": ["tag:k8s-operator"],
			"attr":   ["funnel"],
		},
```

Save and create a new [Oath for the Tailscale Operator](https://login.tailscale.com/admin/settings/oauth)

a) Select these scopes: `Core` and `Auth Keys`.
b) Make sure that you add `tag:k8s` and `tag:k8s-operator` to these scopes.

Save the `Oath ID` and `Oath Secret` to these variables:

```bash
export TAILSCALE_OATH_CLIENT_ID=YOUR_TAILSCALE_OATH_CLIENT_ID
export TAILSCALE_OATH_CLIENT_SECRET=YOUR_TAILSCALE_OATH_CLIENT_SECRET  
```

Install the Tailscale Operator through Helm

```bash
helm repo add tailscale https://pkgs.tailscale.com/helmcharts
helm repo update
helm upgrade \
    --install tailscale-operator tailscale/tailscale-operator \
    --namespace=tailscale \
    --create-namespace \
    --set-string oauth.clientId=$TAILSCALE_OATH_CLIENT_ID \
    --set-string oauth.clientSecret=$TAILSCALE_OATH_CLIENT_SECRET \
    --wait
```

At this point, we can let ArgoCD pick up the files on this directory and deploy it to the cluster. You can get the Funnel FQDN from the Tailscale Admin console
