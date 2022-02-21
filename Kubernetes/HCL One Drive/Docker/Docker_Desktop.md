Insecure registery settings 

 

{ 

  "registry-mirrors": [], 

  "insecure-registries": [ 

    "comlnx94.prod.hclpnp.com", 

    "9.26.139.216" 

  ], 

  "debug": true, 

  "experimental": false 

} 

 

https://github.com/docker/for-win/issues/5305 

 

Docker Desktop will not start, or: "This error may also indicate that the docker daemon is not running 

 

 

Steps: 

Open "Turn Windows features on or off" 

Turn Hyper-V off (uncheck box, making sure all sub-components are marked as off) 

Hit "Ok" - your machine will reboot 

When your computer starts up again, open "Turn Windows features on or off" and turn Hyper-V back on. Your machine will reboot again. 
