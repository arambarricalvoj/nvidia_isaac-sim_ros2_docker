# Warnings - Introducción

Salen carpetas y directorios de omniverse con un candado rojo porque no los encuentra... 
- 2025-12-04T09:46:07Z [188,975ms] [Warning] [omni.kit.window.filepicker.model] Failed to find item at 'https://omniverse-content-production.s3-us-west-2.amazonaws.com/'


<!-- La mayoría de warnings son deprecaciones. Otros son por no haber configurado un servidor de Nucleus (OmniHub) y otro porque no encuentra las condifuraciones específicas, por lo que aplica las de por defecto.

No hay errores en la ejecución. Habrá que revisar si funciona OK al trabajar con el programa.

# Detalles

- [Warning] [omni.datastore] OmniHub is inaccessible:

Indica que OmniHub no es accesible. Si no trabajamos con OmniHub se puede ignorar.

OmniHub es el servicio de colaboración de Omniverse Nucleus.
Funciona como un servidor local o en red que gestiona proyectos, assets y sincronización entre usuarios.
Se instala en una máquina o en un servidor de tu organización, y actúa como “hub” para compartir escenas, modelos y datos.

Si configuramos OmniHub en la red local o en el host, añadir lo siguiente en el ``run.sh``:
```bash 
 -e OMNI_SERVER=http://<host-ip>:3009 \
 -e OMNI_USER=tu_usuario \
 -e OMNI_PASS=tu_password \
 -v ~/omniverse/nucleus:/root/omniverse/nucleus:rw \
```

--

- [Warning] [gpu.foundation.plugin] IOMMU is enabled.

Detecta que el kernel de Linux tiene activado IOMMU (Input–Output Memory Management Unit).

IOMMU es una característica del kernel que gestiona cómo los dispositivos (como la GPU) acceden a la memoria.
En entornos con Docker + NVIDIA, Isaac Sim detecta que está activo y lanza el warning porque en algunos casos puede afectar al rendimiento o a la compatibilidad con ciertas extensiones gráficas.
No impide que la simulación funcione, pero NVIDIA lo marca para que conocer que hay una capa extra de traducción de memoria.

Si Isaac Sim corre con GPU y no hay problemas de rendimiento, se puede dejar. Es solo informativo.

Para desactivar IOMMU en el kernel:
Edita la línea de arranque de GRUB (/etc/default/grub), añadiendo al parámetro GRUB_CMDLINE_LINUX_DEFAULT:

```bash
intel_iommu=off
```
o en AMD:
```bash
amd_iommu=off
```
Luego actualiza GRUB:
```bash 
sudo update-grub
```
Reinicia el sistema. Esto desactiva IOMMU globalmente, lo que elimina el warning.

--

- [Warning] [omni.log] Source: omni.hydra was already registered.

Significa que el módulo o extensión omni.hydra —que gestiona el renderizado Hydra— se ha registrado más de una vez durante el arranque.

No es un error crítico: el motor detecta que la extensión ya estaba cargada y simplemente lo avisa. Suele ocurrir cuando varias extensiones o scripts llaman a la misma librería Hydra en paralelo. No afecta al rendimiento ni a la simulación, salvo que tengas conflictos de versiones de extensiones.

Cómo solucionarlo:
1. Ignorarlo si todo funciona bien Es un warning benigno. Isaac Sim seguirá funcionando con GPU y renderizado normal.

2. Revisar extensiones duplicadas

3. Mira en tu carpeta de configuración (~/.nvidia-omniverse/config o kit/exts) si tienes varias versiones de omni.hydra.

4. A veces ocurre si instalas plugins adicionales o si tu Dockerfile añade extensiones duplicadas.

5. Desactivar extensiones redundantes
En el menú de Isaac Sim → Window → Extensions, busca omni.hydra.
Si ves varias instancias, desactiva las que no uses.

6. Mantener imagen limpia
Como usas la imagen oficial nvcr.io/nvidia/isaac-sim:4.5.0, lo normal es que solo haya una copia.
Si añadiste paquetes o extensiones manualmente, revisa que no hayas duplicado Hydra.

--

- [Warning] [omni.isaac.dynamic_control] omni.isaac.dynamic_control is deprecated as of Isaac Sim 4.5. No action is needed from end-users.

Es un warning informativo.

--

- [Warning] [omni.replicator.core.scripts.extension] No material configuration file, adding configuration to material settings directly.

Proviene del módulo OmniReplicator de Isaac Sim, que se usa para generación de datos sintéticos (dataset creation, synthetic training, etc.).

OmniReplicator busca un archivo de configuración de materiales (normalmente un .json o .yaml) para definir cómo aplicar texturas, colores, rugosidad, etc. en los objetos de la escena.
Al no encontrarlo, aplica la configuración directamente en los ajustes internos por defecto.
Es un aviso informativo: la simulación sigue funcionando, pero no tienes un archivo externo que controle los materiales.

Cómo solucionarlo:
1. Ignorarlo si no usas Replicator Si tu objetivo es solo simular robots con ROS2 y GPU, este warning no afecta en nada. Isaac Sim aplica valores estándar.
2. Crear un archivo de configuración de materiales Si planeas usar Replicator para generación de datasets, conviene definir un archivo de configuración. Ejemplo mínimo (materials.json):

```json
{
  "materials": {
    "default": {
      "roughness": 0.5,
      "metallic": 0.0,
      "baseColor": [1.0, 1.0, 1.0]
    }
  }
}
```
Y en el script de Replicator:

```python
import omni.replicator.core as rep
rep.materials.load("materials.json")
```

3. Revisar los scripts. Si ya se usa Replicator, asegurarse de que los scripts apunten a un archivo válido. El warning indica que no lo encuentra.

--

- [Warning] [omni.isaac.block_world] ['omni.isaac.block_world'] has been deprecated in favor of ['isaacsim.asset.importer.heightmap']. Please update your code accordingly.

La extensión omni.isaac.block_world se usaba para generar mundos basados en bloques o terrenos simples.
A partir de Isaac Sim 4.5, esa extensión ha quedado obsoleta y se recomienda usar isaacsim.asset.importer.heightmap.
El motor te avisa para que migres tu código, porque en futuras versiones block_world podría desaparecer.

Cómo solucionarlo:
1. Si no se usa block_world directamente: ignorar el warning. Isaac Sim lo carga internamente por compatibilidad, pero no afecta a la simulación.

2. Si tienes scripts que usan block_world.
Sustituye las llamadas a omni.isaac.block_world por el nuevo módulo isaacsim.asset.importer.heightmap.
El nuevo módulo permite importar terrenos a partir de heightmaps (mapas de alturas), lo que da más flexibilidad y realismo.

3. Ejemplo de migración 

Antes:

```python
import omni.isaac.block_world as bw
bw.create_block_world(size=(10,10), block_size=1.0)
```
Ahora:

```python
import isaacsim.asset.importer.heightmap as hm
hm.import_heightmap("path/to/heightmap.png", scale=(10,10,2))
```

4. Documentación oficial NVIDIA recomienda revisar la guía de Isaac Sim 4.5 sobre el Heightmap Importer, donde se explican las opciones de escala, texturas y materiales.
https://docs.isaacsim.omniverse.nvidia.com/latest/py/source/extensions/isaacsim.asset.importer.heightmap/docs/index.html

--

- [Warning] [isaacsim.sensors.rtx.ui.extension] config_dir_path /isaac-sim/exts/isaacsim.sensors.rtx/data/lidar_configs

Proviene de la extensión de sensores RTX en Isaac Sim, concretamente de la parte de LiDAR.

La extensión está intentando acceder al directorio de configuración de LiDAR (lidar_configs) dentro de la imagen (/isaac-sim/exts/isaacsim.sensors.rtx/data/lidar_configs).
El warning indica que no encuentra un archivo de configuración específico o que está usando la ruta por defecto.
Isaac Sim sigue funcionando: simplemente carga configuraciones internas de LiDAR en lugar de un archivo externo.

Cómo solucionarlo:
1. Ignorarlo si no se usa LiDAR personalizado. Si no se necesita modificar parámetros de LiDAR, el warning no afecta a la simulación. Isaac Sim aplica configuraciones estándar.

2. Verificar que el directorio existe en tu contenedor

Entra al contenedor y revisar:

```bash
ls /isaac-sim/exts/isaacsim.sensors.rtx/data/lidar_configs
```

Si la carpeta está vacía, significa que no hay configuraciones adicionales instaladas.

Crear tus propios archivos de configuración de LiDAR
Definir un archivo .json con parámetros de LiDAR (resolución angular, rango, ruido, etc.).

Ejemplo mínimo (lidar_config.json):

```json
{
  "horizontal_resolution": 0.2,
  "vertical_resolution": 1.0,
  "max_range": 100.0,
  "noise_stddev": 0.01
}
```
Colocarlo en /isaac-sim/exts/isaacsim.sensors.rtx/data/lidar_configs y referenciar el archivo en el script.

Revisar los scripts de sensores. Si ya se usa LiDAR en Isaac Sim, asegurarse de que los scripts apunten a un archivo válido en esa ruta. El warning indica que no lo encuentra.

Si la carpeta no está vacía, lo que indica es que la extensión de sensores RTX está informando la ruta que usa para buscar configuraciones.
Es un aviso de inicialización, no un error.
El motor está diciendo: “voy a usar esta carpeta como config_dir_path”.
Si no encuentra un archivo específico solicitado por un script, entonces sí daría un error, pero en este caso solo estaría notificando la ruta.

--

- [Warning] [omni.isaac.occupancy_map] omni.isaac.occupancy_map has been deprecated in favor of isaacsim.asset.gen.omap. Please update your code accordingly.

Otro aviso de deprecación en Isaac Sim 4.5.

La extensión omni.isaac.occupancy_map se usaba para generar mapas de ocupación (occupancy maps) a partir de escenas o entornos.
En Isaac Sim 4.5, esa extensión ha quedado obsoleta y se reemplaza por isaacsim.asset.gen.omap.
El motor te avisa para que migres tu código, porque en futuras versiones la extensión antigua puede desaparecer.

Cómo solucionarlo:
1. Si no se usa occupancy maps directamente se puedes ignorar el warning. Isaac Sim lo carga por compatibilidad, pero no afecta a la simulación.
2. Si hay scripts que usan omni.isaac.occupancy_map: sustituir las llamadas por el nuevo módulo isaacsim.asset.gen.omap. La API es similar, pero más flexible y preparada para futuros desarrollos.
3. Ejemplo de migración 

Antes:

```python
import omni.isaac.occupancy_map as omap
omap.create_occupancy_map(resolution=0.1, size=(10,10))
```

Ahora:

```python
import isaacsim.asset.gen.omap as omap
omap.generate(resolution=0.1, size=(10,10))
```

4. Ventajas del nuevo módulo: mejor integración con assets y escenas complejas, soporte extendido para generación automática de mapas en pipelines de simulación, preparado para trabajar con datasets y replicator.

--

- 2025-12-03 15:53:28 [23,346ms] [Warning] [omni.isaac.scene_blox] omni.isaac.scene_blox has been deprecated in favor of isaacsim.replicator.scene_blox. Please update your code accordingly.

Otro aviso de deprecación en Isaac Sim 4.5.

La extensión omni.isaac.scene_blox se usaba para construir escenas modulares (bloques de entorno, objetos, layouts).
NVIDIA la ha marcado como obsoleta y ahora recomienda usar isaacsim.replicator.scene_blox, que está integrada con el sistema de Replicator.
El motor avisa para que se migre el código, porque en futuras versiones la extensión antigua puede desaparecer.

Cómo solucionarlo:
1. Si no se usa scene_blox directamente: ignorar el warning. Isaac Sim lo carga por compatibilidad, pero no afecta a la simulación.

2. Si hay scripts que usan omni.isaac.scene_blox

Sustituir las importaciones por el nuevo módulo:

```python
# Antes
import omni.isaac.scene_blox as sb
sb.create_scene(...)
```

```python
# Ahora
import isaacsim.replicator.scene_blox as sb
sb.create_scene(...)
```

La API es muy similar, pero ahora está pensada para integrarse con pipelines de generación de datasets y replicación de escenas.

4. Ventajas del nuevo módulo: mejor integración con OmniReplicator (para generación de datos sintéticos), soporte extendido para escenas complejas y parametrizadas, preparado para trabajar con assets y configuraciones modernas de Isaac Sim.

--

- 2025-12-03 15:53:28 [23,376ms] [Warning] [omni.isaac.synthetic_recorder] omni.isaac.synthetic_recorder has been deprecated in favor of isaacsim.replicator.synthetic_recorder. Please update your code accordingly.

- 2025-12-03 15:53:28 [23,389ms] [Warning] [omni.isaac.throttling] omni.isaac.throttling has been deprecated in favor of isaacsim.core.throttling. Please update your code accordingly.

- 2025-12-03 15:53:28 [23,391ms] [Warning] [omni.isaac.throttling.throttling] omni.isaac.throttling.throttling has been deprecated in favor of isaacsim.core.throttling.extension. Please update your code accordingly.

- 2025-12-03 15:53:28 [23,435ms] [Warning] [omni.isaac.cortex] omni.isaac.cortex has been deprecated in favor of isaacsim.cortex.framework. Please update your code accordingly.

- 2025-12-03 15:53:28 [23,440ms] [Warning] [omni.isaac.cortex.sample_behaviors] omni.isaac.cortex.sample_behaviors has been deprecated in favor of isaacsim.cortex.behaviors. Please update your code accordingly.

- 2025-12-03 15:53:28 [23,686ms] [Warning] [omni.isaac.extension_templates] omni.isaac.extension_templates has been deprecated in favor of isaacsim.examples.extension. Please update your code accordingly.

- 2025-12-03 15:53:29 [24,905ms] [Warning] [omni.isaac.occupancy_map.ui] omni.isaac.occupancy_map.ui has been deprecated in favor of isaacsim.asset.gen.omap.ui. Please update your code accordingly.

- 2025-12-03 15:53:30 [25,051ms] [Warning] [omni.kit.pipapi.pipapi] extension omni.kit.widget.cache_indicator-3.0.1 has a [python.pipapi] entry, but use_online_index=true is not set. It doesn't do anything and can be removed.

- 2025-12-03 15:53:30 [25,376ms] [Warning] [omni.isaac.physics_inspector] omni.isaac.physics_inspector has been deprecated.Replaced by Physics Visualization tools


- 2025-12-03 15:53:31 [26,747ms] [Warning] [omni.isaac.asset_browser] omni.isaac.asset_browser has been deprecated in favor of isaacsim.asset.browser. Please update your code accordingly.

- 2025-12-03 15:53:31 [26,754ms] [Warning] [omni.isaac.assets_check] omni.isaac.assets_check has been deprecated in favor of isaacsim.asset.browser. Please update your code accordingly.

- 2025-12-03 15:53:31 [26,761ms] [Warning] [omni.isaac.cloner] omni.isaac.cloner has been deprecated in favor of isaacsim.core.cloner. Please update your code accordingly.

- 2025-12-03 15:53:31 [26,791ms] [Warning] [omni.isaac.core.physics_context.physics_context] omni.isaac.core.physics_context.physics_context has been deprecated in favor of isaacsim.core.api.physics_context.physics_context. Please update your code accordingly.

- 2025-12-03 15:53:31 [26,794ms] [Warning] [omni.isaac.core.simulation_context.simulation_context] omni.isaac.core.simulation_context.simulation_context has been deprecated in favor of isaacsim.core.api.simulation_context.simulation_context. Please update your code accordingly.

- 2025-12-03 15:53:31 [26,796ms] [Warning] [omni.isaac.core.world.world] omni.isaac.core.world.world has been deprecated in favor of isaacsim.core.api.world.world. Please update your code accordingly.

- 2025-12-03 15:53:31 [26,797ms] [Warning] [omni.isaac.core] omni.isaac.core has been deprecated in favor of isaacsim.core.api. Please update your code accordingly.

- 2025-12-03 15:53:31 [26,818ms] [Warning] [omni.isaac.core_nodes] omni.isaac.core_nodes has been deprecated in favor of isaacsim.core.nodes. Please update your code accordingly.

- 2025-12-03 15:53:31 [26,929ms] [Warning] [omni.isaac.franka] omni.isaac.franka has been deprecated in favor of isaacsim.robot.manipulators.examples.franka. Please update your code accordingly.

- 2025-12-03 15:53:31 [26,929ms] [Warning] [omni.isaac.franka.franka] omni.isaac.franka has been deprecated in favor of isaacsim.robot.manipulators.examples.franka. Please update your code accordingly.

- 2025-12-03 15:53:31 [26,929ms] [Warning] [omni.isaac.franka.kinematics_solver] omni.isaac.franka has been deprecated in favor of isaacsim.robot.manipulators.examples.franka. Please update your code accordingly.

- 2025-12-03 15:53:31 [26,935ms] [Warning] [omni.isaac.kit] omni.isaac.kit has been deprecated in favor of isaacsim.simulation_app. Please update your code accordingly.

- 2025-12-03 15:53:31 [26,940ms] [Warning] [omni.isaac.lula] omni.isaac.lula has been deprecated in favor of isaacsim.robot_motion.lula. Please update your code accordingly.

- 2025-12-03 15:53:32 [26,969ms] [Warning] [omni.isaac.lula_test_widget] omni.isaac.lula_test_widget has been deprecated in favor of isaacsim.robot_motion.lula_test_widget. Please update your code accordingly.

- 2025-12-03 15:53:32 [26,977ms] [Warning] [omni.isaac.manipulators] omni.isaac.manipulators has been deprecated in favor of isaacsim.robot.manipulators. Please update your code accordingly.

- 2025-12-03 15:53:32 [26,978ms] [Warning] [omni.isaac.manipulators.controllers] omni.isaac.manipulators has been deprecated in favor of isaacsim.robot.manipulators. Please update your code accordingly.

- 2025-12-03 15:53:32 [26,979ms] [Warning] [omni.isaac.manipulators.controllers.pick_place_controller] omni.isaac.manipulators has been deprecated in favor of isaacsim.robot.manipulators. Please update your code accordingly.

- 2025-12-03 15:53:32 [26,979ms] [Warning] [omni.isaac.manipulators.controllers.stacking_controller] omni.isaac.manipulators has been deprecated in favor of isaacsim.robot.manipulators. Please update your code accordingly.

- 2025-12-03 15:53:32 [26,981ms] [Warning] [omni.isaac.manipulators.grippers] omni.isaac.manipulators has been deprecated in favor of isaacsim.robot.manipulators. Please update your code accordingly.

- 2025-12-03 15:53:32 [26,982ms] [Warning] [omni.isaac.manipulators.grippers.gripper] omni.isaac.manipulators has been deprecated in favor of isaacsim.robot.manipulators. Please update your code accordingly.

- 2025-12-03 15:53:32 [26,983ms] [Warning] [omni.isaac.manipulators.grippers.parallel_gripper] omni.isaac.manipulators has been deprecated in favor of isaacsim.robot.manipulators. Please update your code accordingly.

- 2025-12-03 15:53:32 [26,983ms] [Warning] [omni.isaac.manipulators.grippers.surface_gripper] omni.isaac.manipulators has been deprecated in favor of isaacsim.robot.manipulators. Please update your code accordingly.
 
- 2025-12-03 15:53:32 [26,985ms] [Warning] [omni.isaac.manipulators.manipulators] omni.isaac.manipulators has been deprecated in favor of isaacsim.robot.manipulators. Please update your code accordingly.

- 2025-12-03 15:53:32 [26,986ms] [Warning] [omni.isaac.manipulators.manipulators.single_manipulator] omni.isaac.manipulators has been deprecated in favor of isaacsim.robot.manipulators. Please update your code accordingly.

- 2025-12-03 15:53:32 [26,994ms] [Warning] [omni.isaac.menu] omni.isaac.menu has been deprecated in favor of isaacsim.gui.menu. Please update your code accordingly.


- 2025-12-03 15:53:32 [27,002ms] [Warning] [omni.isaac.motion_generation] omni.isaac.motion_generation has been deprecated in favor of isaacsim.robot_motion.motion_generation. Please update your code accordingly.

- 2025-12-03 15:53:32 [27,003ms] [Warning] [omni.isaac.motion_generation.articulation_kinematics_solver] omni.isaac.motion_generation has been deprecated in favor of isaacsim.robot_motion.motion_generation. Please update your code accordingly.

- 2025-12-03 15:53:32 [27,003ms] [Warning] [omni.isaac.motion_generation.articulation_motion_policy] omni.isaac.motion_generation has been deprecated in favor of isaacsim.robot_motion.motion_generation. Please update your code accordingly.

- 2025-12-03 15:53:32 [27,004ms] [Warning] [omni.isaac.motion_generation.articulation_trajectory] omni.isaac.motion_generation has been deprecated in favor of isaacsim.robot_motion.motion_generation. Please update your code accordingly.

- 2025-12-03 15:53:32 [27,004ms] [Warning] [omni.isaac.motion_generation.kinematics_interface] omni.isaac.motion_generation has been deprecated in favor of isaacsim.robot_motion.motion_generation. Please update your code accordingly.

- 2025-12-03 15:53:32 [27,006ms] [Warning] [omni.isaac.motion_generation.lula] omni.isaac.motion_generation has been deprecated in favor of isaacsim.robot_motion.motion_generation. Please update your code accordingly.

- 2025-12-03 15:53:32 [27,006ms] [Warning] [omni.isaac.motion_generation.lula.kinematics] omni.isaac.motion_generation has been deprecated in favor of isaacsim.robot_motion.motion_generation. Please update your code accordingly.

- 2025-12-03 15:53:32 [27,007ms] [Warning] [omni.isaac.motion_generation.lula.motion_policies] omni.isaac.motion_generation has been deprecated in favor of isaacsim.robot_motion.motion_generation. Please update your code accordingly.

- 2025-12-03 15:53:32 [27,007ms] [Warning] [omni.isaac.motion_generation.lula.path_planners] omni.isaac.motion_generation has been deprecated in favor of isaacsim.robot_motion.motion_generation. Please update your code accordingly.

- 2025-12-03 15:53:32 [27,008ms] [Warning] [omni.isaac.motion_generation.lula.trajectory_generator] omni.isaac.motion_generation has been deprecated in favor of isaacsim.robot_motion.motion_generation. Please update your code accordingly.

- 2025-12-03 15:53:32 [27,008ms] [Warning] [omni.isaac.motion_generation.motion_policy_controller] omni.isaac.motion_generation has been deprecated in favor of isaacsim.robot_motion.motion_generation. Please update your code accordingly.

- 2025-12-03 15:53:32 [27,009ms] [Warning] [omni.isaac.motion_generation.motion_policy_interface] omni.isaac.motion_generation has been deprecated in favor of isaacsim.robot_motion.motion_generation. Please update your code accordingly.

- 2025-12-03 15:53:32 [27,009ms] [Warning] [omni.isaac.motion_generation.path_planner_visualizer] omni.isaac.motion_generation has been deprecated in favor of isaacsim.robot_motion.motion_generation. Please update your code accordingly.

- 2025-12-03 15:53:32 [27,010ms] [Warning] [omni.isaac.motion_generation.path_planning_interface] omni.isaac.motion_generation has been deprecated in favor of isaacsim.robot_motion.motion_generation. Please update your code accordingly.

- 2025-12-03 15:53:32 [27,010ms] [Warning] [omni.isaac.motion_generation.trajectory] omni.isaac.motion_generation has been deprecated in favor of isaacsim.robot_motion.motion_generation. Please update your code accordingly.

- 2025-12-03 15:53:32 [27,010ms] [Warning] [omni.isaac.motion_generation.world_interface] omni.isaac.motion_generation has been deprecated in favor of isaacsim.robot_motion.motion_generation. Please update your code accordingly.

- 2025-12-03 15:53:32 [27,018ms] [Warning] [omni.isaac.nucleus] omni.isaac.nucleus has been deprecated in favor of isaacsim.storage.native. Please update your code accordingly.

- 2025-12-03 15:53:32 [27,018ms] [Warning] [omni.isaac.nucleus.nucleus] omni.isaac.nucleus.nucleus has been deprecated in favor of isaacsim.storage.native. Please update your code accordingly.

- 2025-12-03 15:53:32 [27,024ms] [Warning] [omni.isaac.quadruped] omni.isaac.quadruped has been deprecated in favor of isaacsim.robot.policy.examples. Please update your code accordingly.


- 2025-12-03 15:53:32 [27,038ms] [Warning] [omni.isaac.sensor] omni.isaac.sensor has been deprecated in favor of isaacsim.sensors.camera, isaacsim.sensors.physics, isaacsim.sensors.physx, and isaacsim.sensors.rtx. Please update your code accordingly.
2025-12-03 15:53:32 [27,039ms] [Warning] [omni.isaac.sensor.camera] omni.isaac.sensor.camera has been deprecated in favor of isaacsim.sensors.camera.camera. Please update your code accordingly.
2025-12-03 15:53:32 [27,039ms] [Warning] [omni.isaac.sensor.camera_view] omni.isaac.sensor.camera_view has been deprecated in favor of isaacsim.sensors.camera.camera_view. Please update your code accordingly.
2025-12-03 15:53:32 [27,040ms] [Warning] [omni.isaac.sensor.commands] omni.isaac.sensor.commands has been deprecated in favor of isaacsim.sensors.physics.commands, isaacsim.sensors.physx.commands, and isaacsim.sensors.rtx.commands. Please update your code accordingly.
2025-12-03 15:53:32 [27,040ms] [Warning] [omni.isaac.sensor.contact_sensor] omni.isaac.sensor.contact_sensor has been deprecated in favor of isaacsim.sensors.physics.contact_sensor. Please update your code accordingly.
2025-12-03 15:53:32 [27,041ms] [Warning] [omni.isaac.sensor.imu_sensor] omni.isaac.sensor.imu_sensor has been deprecated in favor of isaacsim.sensors.physics.imu_sensor. Please update your code accordingly.
2025-12-03 15:53:32 [27,041ms] [Warning] [omni.isaac.sensor.lidar_rtx] omni.isaac.sensor.lidar_rtx has been deprecated in favor of isaacsim.sensors.rtx.lidar_rtx. Please update your code accordingly.
2025-12-03 15:53:32 [27,042ms] [Warning] [omni.isaac.sensor.rotating_lidar_physX] omni.isaac.sensor.imu_sensor has been deprecated in favor of isaacsim.sensors.physix.rotating_lidar_physX. Please update your code accordingly.
2025-12-03 15:53:32 [27,045ms] [Warning] [omni.isaac.sensor.scripts.samples.contact_sensor] omni.isaac.sensor.scripts.samples.contact_sensor has been deprecated in favor of isaacsim.sensors.physics.scripts.samples.contact_sensor. Please update your code accordingly.
2025-12-03 15:53:32 [27,045ms] [Warning] [omni.isaac.sensor.scripts.samples.imu_sensor] omni.isaac.sensor.scripts.samples.imu_sensor has been deprecated in favor of isaacsim.sensors.physics.scripts.samples.imu_sensor. Please update your code accordingly.
2025-12-03 15:53:32 [27,046ms] [Warning] [omni.isaac.sensor.scripts.samples.lightbeam_sensor] omni.isaac.sensor.scripts.samples.lightbeam_sensor has been deprecated in favor of isaacsim.sensors.physx.scripts.samples.lightbeam_sensor. Please update your code accordingly.

- 2025-12-03 15:53:32 [27,060ms] [Warning] [omni.isaac.surface_gripper] omni.isaac.surface_gripper has been deprecated in favor of isaacsim.robot.surface_gripper. Please update your code accordingly.

- 2025-12-03 15:53:32 [27,066ms] [Warning] [omni.isaac.universal_robots] omni.isaac.universal_robots has been deprecated in favor of isaacsim.robot.manipulators.examples.universal_robots. Please update your code accordingly.
2025-12-03 15:53:32 [27,066ms] [Warning] [omni.isaac.universal_robots.kinematics_solver] omni.isaac.franka has been deprecated in favor of isaacsim.robot.manipulators.examples.universal_robots. Please update your code accordingly.
2025-12-03 15:53:32 [27,067ms] [Warning] [omni.isaac.universal_robots.ur10] omni.isaac.franka has been deprecated in favor of isaacsim.robot.manipulators.examples.universal_robots. Please update your code accordingly.

- 2025-12-03 15:53:32 [27,458ms] [Warning] [omni.isaac.version] omni.isaac.version has been deprecated in favor of isaacsim.core.version. Please update your code accordingly.


- 2025-12-03 15:53:32 [27,570ms] [Warning] [omni.isaac.wheeled_robots] omni.isaac.wheeled_robots has been deprecated in favor of isaacsim.robot.wheeled_robots. Please update your code accordingly.
2025-12-03 15:53:32 [27,571ms] [Warning] [omni.isaac.wheeled_robots.controllers] omni.isaac.wheeled_robots has been deprecated in favor of isaacsim.robot.wheeled_robots. Please update your code accordingly.
2025-12-03 15:53:32 [27,572ms] [Warning] [omni.isaac.wheeled_robots.controllers.ackermann_controller] omni.isaac.wheeled_robots has been deprecated in favor of isaacsim.robot.wheeled_robots. Please update your code accordingly.
2025-12-03 15:53:32 [27,572ms] [Warning] [omni.isaac.wheeled_robots.controllers.differential_controller] omni.isaac.wheeled_robots has been deprecated in favor of isaacsim.robot.wheeled_robots. Please update your code accordingly.
2025-12-03 15:53:32 [27,572ms] [Warning] [omni.isaac.wheeled_robots.controllers.holonomic_controller] omni.isaac.wheeled_robots has been deprecated in favor of isaacsim.robot.wheeled_robots. Please update your code accordingly.
2025-12-03 15:53:32 [27,573ms] [Warning] [omni.isaac.wheeled_robots.controllers.quintic_path_planner] omni.isaac.wheeled_robots has been deprecated in favor of isaacsim.robot.wheeled_robots. Please update your code accordingly.
2025-12-03 15:53:32 [27,573ms] [Warning] [omni.isaac.wheeled_robots.controllers.stanley_control] omni.isaac.wheeled_robots has been deprecated in favor of isaacsim.robot.wheeled_robots. Please update your code accordingly.
2025-12-03 15:53:32 [27,573ms] [Warning] [omni.isaac.wheeled_robots.controllers.wheel_base_pose_controller] omni.isaac.wheeled_robots has been deprecated in favor of isaacsim.robot.wheeled_robots. Please update your code accordingly.
2025-12-03 15:53:32 [27,574ms] [Warning] [omni.isaac.wheeled_robots.impl] omni.isaac.wheeled_robots has been deprecated in favor of isaacsim.robot.wheeled_robots. Please update your code accordingly.
2025-12-03 15:53:32 [27,576ms] [Warning] [omni.isaac.wheeled_robots.robots] omni.isaac.wheeled_robots has been deprecated in favor of isaacsim.robot.wheeled_robots. Please update your code accordingly.
2025-12-03 15:53:32 [27,576ms] [Warning] [omni.isaac.wheeled_robots.robots.holonomic_robot_usd_setup] omni.isaac.wheeled_robots has been deprecated in favor of isaacsim.robot.wheeled_robots. Please update your code accordingly.
2025-12-03 15:53:32 [27,576ms] [Warning] [omni.isaac.wheeled_robots.robots.wheeled_robot] omni.isaac.wheeled_robots has been deprecated in favor of isaacsim.robot.wheeled_robots. Please update your code accordingly.

- 2025-12-03 15:53:32 [27,584ms] [Warning] [omni.isaac.window.about] omni.isaac.window.about has been deprecated in favor of isaacsim.app.about. Please update your code accordingly.
2025-12-03 15:53:32 [27,584ms] [Warning] [omni.isaac.window.about.about] omni.isaac.window.about.about has been deprecated in favor of isaacsim.app.about.about. Please update your code accordingly.

- 2025-12-03 15:53:32 [27,736ms] [Warning] [omni.isaac.range_sensor.examples] omni.isaac.range_sensor.examples has been deprecated in favor of isaacsim.sensors.physx.examples. Please update your code accordingly.
2025-12-03 15:53:32 [27,737ms] [Warning] [omni.isaac.range_sensor.examples.lidar_info] omni.isaac.range_sensor.examples.lidar_info has been deprecated in favor of isaacsim.sensors.physx.examples.lidar_info. Please update your code accordingly.
2025-12-03 15:53:32 [27,737ms] [Warning] [omni.isaac.range_sensor.examples.generic_info] omni.isaac.range_sensor.examples.generic_info has been deprecated in favor of isaacsim.sensors.physx.examples.generic_info. Please update your code accordingly.

- 2025-12-03 15:53:33 [28,045ms] [Warning] [omni.kit.property.isaac] omni.kit.property.isaac has been deprecated in favor of isaacsim.gui.property. Please update your code accordingly.
2025-12-03 15:53:33 [28,050ms] [Warning] [omni.kit.property.isaac.widgets] omni.kit.property.isaac.widgets has been deprecated in favor of isaacsim.gui.property.widgets. Please update your code accordingly.

- 2025-12-03 15:53:33 [28,147ms] [Warning] [omni.replicator.isaac] omni.replicator.isaac has been deprecated in favor of isaacsim.replicator.domain_randomization, isaacsim.replicator.examples, isaacsim.replicator.writers. Please update your code accordingly.

- 2025-12-03 15:53:33 [28,356ms] [Warning] [omni.isaac.range_sensor.ui] omni.isaac.range_sensor.ui has been deprecated in favor of isaacsim.sensors.physx.ui. Please update your code accordingly.
2025-12-03 15:53:33 [28,357ms] [Warning] [omni.isaac.range_sensor.ui.menu] omni.isaac.range_sensor.ui.menu has been deprecated in favor of isaacsim.sensors.physx.ui.menu. Please update your code accordingly.

-

-

-

--

- 2025-12-03 15:53:34 [29,084ms] [Warning] [carb.audio.device] audio device is misconfigured or broken {deviceIndex = 0, name = 'default'} (The device is likely misconfigured, check your $HOME/.asoundrc)
2025-12-03 15:53:34 [29,084ms] [Warning] [carb.audio.output] failed to retrieve the capabilities for device 0 {result = eDeviceLost (2)}
2025-12-03 15:53:34 [29,084ms] [Warning] [carb.audio.context] failed to set the requested output during context creation.  Using a null streamer instead {result = eDeviceLost (2)}

Relacionados con el subsistema de audio dentro de Isaac Sim (basado en Carb Audio).

carb.audio.device: el dispositivo de audio por defecto (deviceIndex = 0, name = 'default') está mal configurado o no disponible.
carb.audio.output: no se pudieron obtener las capacidades del dispositivo de salida (probablemente porque no existe o está roto).
carb.audio.context: al no poder usar el dispositivo, Isaac Sim crea un null streamer (es decir, desactiva el audio).
En resumen: Isaac Sim intentó inicializar audio, pero no encontró un dispositivo válido, así que desactiva el sonido y sigue funcionando.

Cómo solucionarlo:
1. Ignorarlo si no se necesita audio. Si la simulación no depende de sonido, dejarlo tal cual. Isaac Sim funcionará sin audio.

2. Configurar ALSA/PulseAudio en el host. El contenedor intenta usar el dispositivo de audio del host.
Revisa la configuración en ~/.asoundrc o /etc/asound.conf.
Ejemplo mínimo de .asoundrc para usar PulseAudio:

```plaintext
pcm.!default {
  type pulse
  fallback "sysdefault"
}
ctl.!default {
  type pulse
  fallback "sysdefault"
}
```

Pasar el dispositivo de audio al contenedor
Añade al docker run:

```bash
--device /dev/snd \
-e PULSE_SERVER=unix:/run/user/1000/pulse/native \
-v /run/user/1000/pulse:/run/user/1000/pulse
```
Esto conecta el contenedor con el servidor de audio del host.

Verificar que el host tiene audio funcionando
Si el host no tiene tarjeta de sonido activa o el servidor PulseAudio/ALSA está roto, el contenedor tampoco podrá usarlo.
Comprobar con:

```bash
aplay -l
pactl list short sinks
```

--

- 2025-12-03 15:53:34 [29,282ms] [Warning] [rtx.scenedb.plugin] SceneDbContext : TLAS limit buffer size 7508933632
2025-12-03 15:53:34 [29,282ms] [Warning] [rtx.scenedb.plugin] SceneDbContext : TLAS limit : valid false, within: false
2025-12-03 15:53:34 [29,282ms] [Warning] [rtx.scenedb.plugin] SceneDbContext : TLAS limit : decrement: 167690, decrement size: 7433845248
2025-12-03 15:53:34 [29,282ms] [Warning] [rtx.scenedb.plugin] SceneDbContext : New limit 9574251 (slope: 447, intercept: 13179904)
2025-12-03 15:53:34 [29,282ms] [Warning] [rtx.scenedb.plugin] SceneDbContext : TLAS limit buffer size 4287216384
2025-12-03 15:53:34 [29,282ms] [Warning] [rtx.scenedb.plugin] SceneDbContext : TLAS limit : valid true, within: true

Vienen del plugin RTX SceneDB de Isaac Sim, que gestiona las estructuras de aceleración de ray tracing (TLAS = Top-Level Acceleration Structure).
TLAS limit buffer size: el motor está calculando cuánta memoria de GPU necesita para almacenar las estructuras de ray tracing de la escena.
valid false / within false: inicialmente, el límite calculado no era válido (probablemente demasiado grande para la memoria disponible).
decrement: el motor ajusta el tamaño del buffer, reduciéndolo para que encaje en la memoria de la GPU.
New limit: se recalcula un límite más pequeño, con parámetros de ajuste (slope, intercept).
valid true / within true: finalmente encuentra un tamaño que sí cabe en la memoria de la GPU, y lo aplica.
En otras palabras: Isaac Sim está autotuneando el tamaño de las estructuras de ray tracing para que no se desborde la memoria de tu GPU.

Cómo solucionarlo:
1. Ignorarlo si todo funciona bien, es un warning informativo: el motor ajusta automáticamente los límites. No es un error crítico.

2. Si hay problemas de rendimiento o memoria puede ser que la escena sea muy grande o la GPU tenga menos memoria de lo ideal.
En ese caso, conviene reducir la complejidad de la escena (menos polígonos, menos assets cargados simultáneamente).

3. Configurar manualmente TLAS limits
En algunos casos avanzados, ajustar parámetros de RTX SceneDB en los archivos de configuración (kit/config/rtx.settings.json).
Esto permite fijar límites de memoria para TLAS en lugar de dejar que el motor los calcule dinámicamente.

--

- 2025-12-03 15:53:34 [29,495ms] [Warning] [omni.usd-abi.plugin] No setting was found for '/rtx-defaults-transient/meshlights/forceDisable'
2025-12-03 15:53:34 [29,556ms] [Warning] [omni.usd-abi.plugin] No setting was found for '/rtx-defaults/post/dlss/execMode'

- 2025-12-03 15:53:40 [35,528ms] [Warning] [omni.kit.widget.cache_indicator.utils] No library_root key valid path in omniverse.toml
2025-12-03 15:53:42 [37,726ms] [Warning] [omni.kit.widget.cache_indicator.utils] No library_root key valid path in omniverse.toml
2025-12-03 15:53:43 [38,165ms] [Warning] [omni.kit.widget.cache_indicator.utils] No library_root key valid path in omniverse.toml

Crear en el host ```mkdir -p ~/docker/isaac-sim/pkg```

Añadir al run.sh: ```-v ~/docker/isaac-sim/pkg:/root/.local/share/ov/pkg:rw \```

- 2025-12-03 16:09:35 [990,922ms] [Warning] [omni.kit.window.extensions.markdown_renderer] Hyperlink error: omni.hydra.engine.stats/omni.hydra.engine.stats.HydraEngineStats not found
2025-12-03 16:09:35 [990,922ms] [Warning] [omni.kit.window.extensions.markdown_renderer] Hyperlink error: omni.hydra.engine.stats/omni.hydra.engine.stats.get_device_info not found
2025-12-03 16:09:35 [990,922ms] [Warning] [omni.kit.window.extensions.markdown_renderer] Hyperlink error: omni.hydra.engine.stats/omni.hydra.engine.stats.get_mem_stats not found

- [Error] [gpu.foundation.plugin] No carb::graphics::DescriptorSet for pool 1 on device 0

Proviene del plugin de GPU Foundation dentro de Omniverse/Isaac Sim.

DescriptorSet: en gráficos RTX/DirectX/Vulkan, un descriptor set es una estructura que describe cómo la GPU accede a recursos (buffers, texturas, samplers).

El mensaje indica que el motor intentó obtener un DescriptorSet de un pool (grupo de descriptores) en el device 0 (tu GPU principal), pero no lo encontró.
Esto suele ocurrir cuando:la escena o extensión solicita más descriptores de los que el pool tiene disponibles, hay un fallo en la inicialización de recursos gráficos (drivers, memoria, configuración), el motor está ajustando dinámicamente los límites de GPU y no pudo asignar un recurso en ese momento.

Solucionado al añadir en el run.sh:
```bash
-e __GLX_VENDOR_LIBRARY_NAME=nvidia \
```

--

- 2025-12-03 15:53:34 [29,495ms] [Warning] [omni.usd-abi.plugin] No setting was found for '/rtx-defaults-transient/meshlights/forceDisable'
2025-12-03 15:53:34 [29,556ms] [Warning] [omni.usd-abi.plugin] No setting was found for '/rtx-defaults/post/dlss/execMode'
[33.673s] Isaac Sim Full App is loaded.
2025-12-03 15:53:40 [35,528ms] [Warning] [omni.kit.widget.cache_indicator.utils] No library_root key valid path in omniverse.toml
2025-12-03 15:53:42 [37,726ms] [Warning] [omni.kit.widget.cache_indicator.utils] No library_root key valid path in omniverse.toml
2025-12-03 15:53:43 [38,165ms] [Warning] [omni.kit.widget.cache_indicator.utils] No library_root key valid path in omniverse.toml
[948.003s] [ext: omni.kit.registry.nucleus-0.0.0] startup
2025-12-03 16:09:35 [990,922ms] [Warning] [omni.kit.window.extensions.markdown_renderer] Hyperlink error: omni.hydra.engine.stats/omni.hydra.engine.stats.HydraEngineStats not found
2025-12-03 16:09:35 [990,922ms] [Warning] [omni.kit.window.extensions.markdown_renderer] Hyperlink error: omni.hydra.engine.stats/omni.hydra.engine.stats.get_device_info not found
2025-12-03 16:09:35 [990,922ms] [Warning] [omni.kit.window.extensions.markdown_renderer] Hyperlink error: omni.hydra.engine.stats/omni.hydra.engine.stats.get_mem_stats not found

-->

