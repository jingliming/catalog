parameter: {
	namespace?: *"kruise-rollout" | string
	// controller images prefix
	chartRepo?:    string
	chartVersion?: string
	imageRepo?:    string
	imageTag?:     string
	//+usage=imagePullSecret for pulling image
	imagePullSecret?:        string
	useExistedClusterRole?:  *false | bool
	existedClusterRoleName?: *"kubevela-vela-core:manager" | string
	tolerations?: [...#Toleration]
	// +usage=Specify tolerant taint
	#Toleration: {
		key?:     string
		operator: *"Equal" | "Exists"
		value?:   string
		effect?:  "NoSchedule" | "PreferNoSchedule" | "NoExecute"
		// +usage=Specify the period of time the toleration
		tolerationSeconds?: int
	}
	imageTagSuffix?: *"" | string
}
