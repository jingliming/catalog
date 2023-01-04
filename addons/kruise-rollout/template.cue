package main

output: {
	apiVersion: "core.oam.dev/v1beta1"
	kind:       "Application"
	metadata:
		name: "kruise-rollout"
	namespace: "vela-system"
	spec:
		components: [
			{
				name: "kruise-rollout"
				type: "helm"
				properties: {
					repoType: "helm"
					url:      parameter.chartRepo
					chart:    "kruise-rollout"
					version:  parameter.chartVersion
					values: installation: createNamespace: false
					if parameter.imageRepo != _|_  {
						image: {
							repository: parameter.imageRepo
							pullPolicy: "Always"
							if parameter.imageTag != _|_ {
								tag: parameter.imageTag
							}
						}
					}
					if parameter.imagePullSecret != _|_ {
						imagePullSecrets: [
							{
								name: parameter.imagePullSecret
							},
						]
					}
				}
			},
		]
}
