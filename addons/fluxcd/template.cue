package main

import "strings"

// controller images prefix
_base: *"" | string
_bindingClusterRole: {}
_useExistedClusterRole: *false | bool
_existedClusterRoleName: *"kubevela-vela-core:manager" | string

if parameter.useExistedClusterRole != _|_ {
	_useExistedClusterRole: parameter.useExistedClusterRole
}

if parameter.existedClusterRoleName != _|_ {
	_existedClusterRoleName: parameter.existedClusterRoleName
}

_bindingClusterRole: bindingClusterAdmin
if parameter.useExistedClusterRole != _|_ && parameter.useExistedClusterRole == true {
	_bindingClusterRole: bindingClusterRole
}

if parameter.registry != _|_ && parameter.registry != "" && !strings.HasSuffix(parameter.registry, "/") {
	_base: parameter.registry + "/"
}
if parameter.registry == _|_ || parameter.registry == "" || strings.HasSuffix(parameter.registry, "/") {
	_base: parameter.registry
}

_targetNamespace: *"flux-system" | string

if parameter.namespace != _|_ {
	_targetNamespace: parameter.namespace
}

if parameter.imagePullSecret != _|_ {
	_imagePullSecrets: [parameter.imagePullSecret]
}

gitOpsController: [...] | []

kustomizeResourcesCRD: [...] | []

if parameter.onlyHelmComponents != _|_ && parameter.onlyHelmComponents == false {
	gitOpsController: [imageAutomationController, imageReflectorController, kustomizeController]
	kustomizeResourcesCRD: [imagePolicyCRD, imageRepoCRD, imageUpdateCRD, kustomizeCRD]
}

if parameter.onlyHelmComponents == _|_ {
	gitOpsController: [imageAutomationController, imageReflectorController, kustomizeController]
	kustomizeResourcesCRD: [imagePolicyCRD, imageRepoCRD, imageUpdateCRD, kustomizeCRD]
}

output: {
	apiVersion: "core.oam.dev/v1beta1"
	kind:       "Application"
	spec: {
		components: [
//				{
//				type: "k8s-objects"
//				name: "fluxcd-ns"
//				properties: objects: [{
//					apiVersion: "v1"
//					kind:       "Namespace"
//					metadata: name: _targetNamespace
//				}]
//			},
			{
				type: "k8s-objects"
				name: "fluxcd-rbac"
				properties: objects: [
					// auto-generated from original yaml files
					_bindingClusterRole,
				]
			},
			{
				type: "k8s-objects"
				name: "fluxcd-CRD"
				properties: objects: [
							// auto-generated from original yaml files
							bucketCRD,
							gitRepoCRD,
							helmChartCRD,
							helmReleaseCRD,
							helmRepoCRD,
				] + kustomizeResourcesCRD
			},
			helmController,
			sourceController,
		] + gitOpsController
		policies: [
			{
				type: "shared-resource"
				name: "namespace"
				properties: rules: [{
					selector: resourceTypes: ["Namespace"]
				}]
			},
			{
				type: "topology"
				name: "deploy-fluxcd-ns"
				properties: {
					namespace: _targetNamespace
					if parameter.clusters != _|_ {
						clusters: parameter.clusters
					}
					if parameter.clusters == _|_ {
						clusterLabelSelector: {}
					}
				}
			},
			{
				type: "garbage-collect"
				name: "not-gc-CRD"
				properties: {
					rules: [{
						selector: resourceTypes: ["CustomResourceDefinition"]
						strategy: "never"
					},
					]
				}
			},
			{
				type: "apply-once"
				name: "not-keep-CRD"
				properties: {
					rules: [{
						selector: resourceTypes: ["CustomResourceDefinition"]
						strategy: {
							path: ["*"]
						}
					},
					]
				}
			},
		]
	}
}
