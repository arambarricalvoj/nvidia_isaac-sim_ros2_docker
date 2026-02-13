# VNC to a server running nvidia_isaac-sim_ros2_docker

Currently only available in Spanish... sorry :(

# Configuración de x11vnc con Xorg Dummy en Ubuntu

## 0.1 Iniciar sesión automáticamente
Es necesario que inicie sesión automáticamente en el usuario deseado, de lo contrario, no se cargará el entorno gráfico y no se podrá acceder por X11VNC (solo por Remote Login y TigerVNC, que no sirven para ejecutar Isaac Sim).

Configuración > Sistema > Usuarios:

![Activar inicio de sesión automático](img/iniciar_sesion_auto.png)

## 0.2 Instalar, configurar y conectarse por SSH
```bash
sudo apt update
sudo apt install openssh-server
```

```bash
sudo systemctl status ssh
```
Debe aparecer como active (running).

Habilitar SSH para que arranque automáticamente:
```bash
sudo systemctl enable ssh
```

Habilitar el puerto 22 en el firewall y reiniciarlo:
```bash
sudo ufw allow 22/tcp
sudo ufw reload
```

Conexión SSH desde otro host:
```bash
ssh USER_REMOTE@IP_DIRECTION
```

Por seguridad, lo ideal sería añadir claves públicas de forma que solo nos podamos conectar con determinadas claves SSH, pero de momento lo vamos a dejar así.


## 1. Instalar paquetes necesarios
```bash
sudo apt update
sudo apt install x11vnc xserver-xorg-video-dummy
```
## 2. Crear configuración de Xorg dummy
```bash 
sudo nano /etc/X11/xorg.conf.d/10-headless.conf
```
Contenido del fichero de configuración:
```
Section "Device"
    Identifier  "Configured Video Device"
    Driver      "dummy"
    VideoRam    256000
EndSection

Section "Monitor"
    Identifier  "Configured Monitor"
    HorizSync   5.0 - 1000.0
    VertRefresh 5.0 - 200.0
    ModeLine "1920x1080" 148.50 1920 2448 2492 2640 1080 1084 1089 1125 +Hsync +Vsync
EndSection

Section "Screen"
    Identifier  "Default Screen"
    Monitor     "Configured Monitor"
    Device      "Configured Video Device"
    DefaultDepth 24
    SubSection "Display"
        Depth 24
        Modes "1920x1080" "1440x900" "1280x800" "1024x768"
    EndSubSection
EndSection
```

## 3. Configurar contraseña para VNC
```bash
mkdir -p ~/.vnc
x11vnc -storepasswd
```
Esto generará el archivo ``~/.vnc/passwd``.


## 4. Crear servicio systemd para x11vnc
```bash
sudo nano /etc/systemd/system/x11vnc.service
```
Contenido del servicio:
```
[Unit]
Description=Start x11vnc at startup
After=multi-user.target

[Service]
Type=simple
User=isaac_sim_1
Environment=DISPLAY=:0
ExecStart=/usr/bin/x11vnc -display :0 -forever -loop -noxdamage -repeat \
  -rfbauth /home/isaac_sim_1/.vnc/passwd -rfbport 5900 -shared
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
```

## 5. Recargar systemd y habilitar servicio
```bash
sudo systemctl daemon-reload
sudo systemctl enable x11vnc.service
sudo systemctl start x11vnc.service
```

## 6. Verificar estado
```bash
sudo systemctl status x11vnc.service
``` 
Si necesitas comprobar qué display está activo:
```bash
echo $DISPLAY
ps aux | grep Xorg
```

## 7. (Opcional) Reiniciar Xorg dummy manualmente
En caso de problemas:
```bash
sudo pkill Xorg 2>/dev/null || true
DISPLAY=:0 startx -- -config /etc/X11/xorg.conf.d/10-headless.conf &
sudo systemctl restart x11vnc.service
```

## 8. Desactivar dummy y activar monitor físico
Acceder por SHH:
```bash
ssh USER_REMOTE@IP_DIRECTION
```

Renombrar el fichero de configuración del dummy. Hay que quitar la extesnión ``.conf``, ya que Xorg carga la configuración de todos los ficheros con esa terminación:
```bash
sudo mv /etc/X11/xorg.conf.d/10-headless.conf /etc/X11/xorg.conf.d/10-headless.conf.bkp
```

Reiniciamos:
```bash
sudo reboot
```

## 9. Activar dummy y desactivar monitor físico
Acceder por SHH:
```bash
ssh USER_REMOTE@IP_DIRECTION
```

Renombrar el fichero de configuración del dummy. Hay que poner la extesnión ``.conf``, ya que Xorg carga la configuración de todos los ficheros con esa terminación:
```bash
sudo mv /etc/X11/xorg.conf.d/10-headless.conf.bkp /etc/X11/xorg.conf.d/10-headless.conf
```

Reiniciamos:
```bash
sudo reboot
```

<br>

# Configuración de GNOME Remote Desktop (RDP) en Ubuntu mediante `grdctl` (recuperar RDP después de usar VNC)

Esta sección documenta los pasos necesarios para habilitar y configurar **GNOME Remote Desktop (RDP)** desde la línea de comandos, incluyendo la creación manual de certificados TLS y la configuración de credenciales. Esto es necesario para recuperar el servicio de RDP Desktop Sharing después de haber usado x11vnc con Xorg Dummy y solucionar el problema de ``RDP certificate is invalid``.

## 0. Comprobar que Wayland está habilitado en GDM (Gnome Desktop Manager)

GNOME Remote Desktop (RDP) funciona sobre sesiones Wayland. Hay que asegurarse de que **Wayland no está deshabilitado** en la configuración de GDM.

Editar el fichero de configuración de GDM:

```bash
sudo nano /etc/gdm3/custom.conf
```

En ese fichero, asegurarse de que la línea ``WaylandEnable=false`` está comentada. Debe quedar así:
```bash
#WaylandEnable=false
```

Guardar, cerrar el fichero y reiniciar el sistema: 
```bash
sudo reboot
```

## 1. Crear directorio para certificados TLS

GNOME Remote Desktop almacena sus certificados en:
~/.local/share/gnome-remote-desktop/

Si no existe, crearlo:

```bash
mkdir -p ~/.local/share/gnome-remote-desktop/
```

## 2. Generar certificado y clave TLS

GNOME Remote Desktop requiere un certificado TLS válido para iniciar el servidor RDP.
Generar un certificado autofirmado:
```bash
openssl req -new -newkey rsa:4096 -days 720 -nodes -x509 \
  -subj /C=SE/ST=NONE/L=NONE/O=GNOME/CN=gnome.org \
  -out ~/.local/share/gnome-remote-desktop/tls.crt \
  -keyout ~/.local/share/gnome-remote-desktop/tls.key
```

## 3. Registrar el certificado y la clave en GNOME Remote Desktop
```bash
grdctl rdp set-tls-key ~/.local/share/gnome-remote-desktop/tls.key
grdctl rdp set-tls-cert ~/.local/share/gnome-remote-desktop/tls.crt
```

## 4. Establecer credenciales RDP

En versiones recientes de ``grdctl``, la sintaxis correcta es: ``grdctl rdp set-credentials <usuario> <contraseña>``

```bash
grdctl rdp set-credentials my_user my_pass
```

## 5. Habilitar el servidor RDP
```bash
grdctl rdp enable
```

## 6. Verificar el estado del servicio
```bash
grdctl status
```

Debe mostrar algo similar a:
```
RDP:
    Status: enabled
    Port: 3389
    TLS certificate: /home/<user>/.local/share/gnome-remote-desktop/tls.crt
    TLS key: /home/<user>/.local/share/gnome-remote-desktop/tls.key
    Username: (hidden)
    Password: (hidden)
```

## 7. Verificar que el servicio está activo
```bash
systemctl --user status gnome-remote-desktop.service
```

Debe aparecer como active (running).

### El bloqueo de pantalla tiene que estar desactivado. En caso de estar activado y la sesión bloqueada, seguir los siguientes pasos desde terminal:
Comprobarlo con:
```bash
loginctl show-session 1 -p LockedHint
```
Si la respuesta es ``LockedHint=yes``, la sesión está bloqueada. Para desbloquearla:
```bash
loginctl unlock-session 1
```

Ahora ya puedes conectar por RDP y desactivar el bloqueo de pantalla en la sección de seguridad de ajustes, a través de la GUI.


## 8. Abrir puertos en el firewall (UFW)
```bash
sudo ufw allow 3389/tcp
sudo ufw reload
```

Comprobarlo con:
```bash
sudo ufw status
```
## 9. Bibliografía
https://gitlab.gnome.org/GNOME/gnome-remote-desktop#from-command-line
https://gitlab.gnome.org/GNOME/gnome-remote-desktop#tls-key-and-certificate-generation

## Ahora ya podemos modificar usuario y contraseña desde Configuración > Sistemas > Escritorio Remoto > Compartición de Escritorio (Desktop Sharing) 
