package main

_base: string
_rules: [...]
controllerArgs: [...]
_targetNamespace: string
_imagePullSecrets: [...string]
_useExistedClusterRole:  bool
_existedClusterRoleName: string

kustomizeController: {
	// About this name, refer to #429 for details.
	name: "fluxcd-kustomize-controller"
	type: "webservice"
	// dependsOn: ["fluxcd-ns"]
	properties: {
		imagePullPolicy:  "IfNotPresent"
		imagePullSecrets: _imagePullSecrets
		image:            _base + "kustomize-controller:v0.26.0"
		env: [
			{
				name:  "RUNTIME_NAMESPACE"
				value: _targetNamespace
			},
		]
		livenessProbe: {
			httpGet: {
				path: "/healthz"
				port: 9440
			}
			timeoutSeconds: 5
		}
		readinessProbe: {
			httpGet: {
				path: "/readyz"
				port: 9440
			}
			timeoutSeconds: 5
		}
		volumeMounts: {
			emptyDir: [
				{
					name:      "temp"
					mountPath: "/tmp"
				},
			]
		}
	}
	traits: [
		{
			type: "service-account"
			properties: {
				name:   "sa-kustomize-controller"
				create: true
				if _useExistedClusterRole != _|_ && _useExistedClusterRole == true {
					existedClusterRoleName: _existedClusterRoleName
				}
				if _useExistedClusterRole == _|_ || _useExistedClusterRole == false {
					privileges: _rules
				}
			}
		},
		{
			type: "labels"
			properties: {
				"control-plane": "controller"
				// This label is kept to avoid breaking existing 
				// KubeVela e2e tests (makefile e2e-setup).
				"app": "kustomize-controller"
			}
		},
		{
			type: "command"
			properties: {
				args: controllerArgs
			}
		},
	]
}
