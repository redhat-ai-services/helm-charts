# helm-charts

A repository of custom helm charts.

To access charts from this from the cli repository add it:

```sh
helm repo add rh-dse https://rh-datascience-and-edge-practice.github.io/helm-charts/
helm repo update rh-dse
```

To include a chart from this repository in an umbrella chart, include it in your dependencies in your `Chart.yaml` file.

```yaml
apiVersion: v2
name: example-chart
description: A Helm chart for Kubernetes
type: application

version: 0.1.0

appVersion: "1.16.0"

dependencies:
  - name: "odh"
    version: "0.1.3"
    repository: "https://rh-datascience-and-edge-practice.github.io/helm-charts/"
```
