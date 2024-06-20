_useExistedClusterRole:  *false | bool
_existedClusterRoleName: *"kubevela-vela-core:manager" | string

if parameter.useExistedClusterRole != _|_ {
	_useExistedClusterRole: parameter.useExistedClusterRole
}

if parameter.existedClusterRoleName != _|_ {
	_existedClusterRoleName: parameter.existedClusterRoleName
}

output: {
	type: "helm"
	properties: {
		chart:           "vela-rollout"
		version:         parameter.chartVersion
		repoType:        "helm"
		url:             parameter.chartRepo
		targetNamespace: parameter.namespace
		releaseName:     "vela-rollout"
		values: {
			if parameter.imageRepo != _|_ {
				image: {
					repository: parameter.imageRepo
					pullPolicy: "IfNotPresent"
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
			if parameter.imagePullSecret != _|_ {
				imagePullSecrets: [
					{
						name: parameter.imagePullSecret
					},
				]
			}
			if _useExistedClusterRole {
				serviceAccount: {
					exsitedClusterRoleName: _existedClusterRoleName
				}
			}
			if parameter.tolerations != _|_ {
				if len(parameter.tolerations) != 0 {
					tolerations: parameter.tolerations
				}
			}
		}
	}
}
