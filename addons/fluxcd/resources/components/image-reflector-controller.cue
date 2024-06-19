package main

_base: string
_rules: [...]
controllerArgs: [...]
_targetNamespace: string
_imagePullSecrets: [...string]
_useExistedClusterRole:  bool
_existedClusterRoleName: string
_imageTagSuffix:  string

imageReflectorController: {
	// About this name, refer to #429 for details.
	name: "fluxcd-image-reflector-controller"
	type: "webservice"
	// dependsOn: ["fluxcd-ns"]
	properties: {
		imagePullPolicy:  "IfNotPresent"
		imagePullSecrets: _imagePullSecrets
		image:            _base + "image-reflector-controller:v0.19.0" + _imageTagSuffix
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
				{
					name:      "data"
					mountPath: "/data"
				},
			]
		}
	}
	traits: [
		{
			type: "service-account"
			properties: {
				name:   "sa-image-reflector-controller"
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
				"app": "image-reflector-controller"
			}
		},
		{
			type: "command"
			properties: {
				args: controllerArgs
			}
		},
	] + [
		if parameter.tolerations != _|_ {
			if len(parameter.tolerations) != 0 {
				{
					type: "affinity"
					properties: {
						tolerations: parameter.tolerations
					}
				}
			}
		},
	]
}
