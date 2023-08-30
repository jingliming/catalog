package main

_targetNamespace: string
_existedClusterRoleName: string

bindingClusterRole: {
	apiVersion: "rbac.authorization.k8s.io/v1"
	kind:       "ClusterRoleBinding"
	metadata: {
		name: "cluster-reconciler"
	}
	roleRef: {
		apiGroup: "rbac.authorization.k8s.io"
		kind:     "ClusterRole"
		name:     _existedClusterRoleName
	}
	subjects: [{
		kind:      "ServiceAccount"
		name:      "sa-kustomize-controller"
		namespace: _targetNamespace
	}, {
		kind:      "ServiceAccount"
		name:      "sa-helm-controller"
		namespace: _targetNamespace
	}]
}
