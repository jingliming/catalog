parameter: {
	// controller images prefix
	chartRepo?:    string
	chartVersion?: string
	imageRepo?:    string
	imageTag?:     string
	//+usage=imagePullSecret for pulling image
	imagePullSecret?:        string
	useExistedClusterRole?:  *false | bool
	existedClusterRoleName?: *"kubevela-vela-core:manager" | string
}
