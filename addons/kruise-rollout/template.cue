package main

_useExistedClusterRole:  *false | bool
_existedClusterRoleName: *"kubevela-vela-core:manager" | string

if parameter.useExistedClusterRole != _|_ {
	_useExistedClusterRole: parameter.useExistedClusterRole
}

if parameter.existedClusterRoleName != _|_ {
	_existedClusterRoleName: parameter.existedClusterRoleName
}

output: {
	apiVersion: "core.oam.dev/v1beta1"
	kind:       "Application"
	metadata:
		name: "kruise-rollout"
	namespace: parameter.namespace
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
					values: {
						installation: {
							createNamespace: false
							if parameter.namespace != _|_ {
								namespace: parameter.namespace
							}
						}
						if parameter.imageRepo != _|_ {
							image: {
								repository: parameter.imageRepo
								pullPolicy: "Always"
								if parameter.imageTag != _|_ {
									tag: parameter.imageTag
								}
								if parameter.imageTag == _|_ {
									if parameter.imageTagSuffix != _|_ {
										imageTagSuffix: parameter.imageTagSuffix
									}
								}
							}
						}
						if _useExistedClusterRole {
							rbac: exsitedClusterRoleName: _existedClusterRoleName
						}
						if parameter.imagePullSecret != _|_ {
							imagePullSecrets: [
								{
									name: parameter.imagePullSecret
								},
							]
						}
						if parameter.tolerations != _|_ {
							if len(parameter.tolerations) != 0 {
								tolerations: parameter.tolerations
							}
						}
					}
				}
			},
		]
}
