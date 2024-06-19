package main

_base: string
_rules: [...]
controllerArgs: [...]
_targetNamespace:      string
_sourceControllerName: "fluxcd-source-controller"
_imagePullSecrets: [...string]
_useExistedClusterRole:  bool
_existedClusterRoleName: string
_imageTagSuffix:  string

sourceController: {
	// About this name, refer to #429 for details.
	name: _sourceControllerName
	type: "webservice"
	// dependsOn: ["fluxcd-ns"]
	properties: {
		imagePullPolicy:  "IfNotPresent"
		imagePullSecrets: _imagePullSecrets
		image:            _base + "source-controller:v0.25.1" + _imageTagSuffix
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
				path: "/"
				port: 9090
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
		ports: [
			{
				port:     9090
				name:     "http"
				protocol: "TCP"
				expose:   true
			},
		]
		exposeType: "ClusterIP"
	}
	traits: [
		{
			type: "service-account"
			properties: {
				name:   "sa-source-controller"
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
				"app": "source-controller"
			}
		},
		{
			type: "command"
			properties: {
				args: controllerArgs + [
					"--storage-path=/data",
					"--storage-adv-addr=http://" + _sourceControllerName + "." + _targetNamespace + ".svc:9090",
				]
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
