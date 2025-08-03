<div align="center">

<img src="/assets/icons/logo_serviexpress-nobg.png" alt="ServiExpress Logo" width="250"/>

# ServiExpress

### Lleva tu experiencia con expertos al siguiente nivel.

<br/>

[![Dart](https://img.shields.io/badge/Dart-3.7.2-blue?style=for-the-badge&logo=dart)](https://dart.dev/)
[![Flutter](https://img.shields.io/badge/Flutter-3.29.3-blue?style=for-the-badge&logo=flutter)](https://flutter.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-Backend-yellow?style=for-the-badge&logo=firebase)](https://firebase.google.com/)

</div>


## 📌 Descripción

**ServiExpress** es una aplicación móvil multiplataforma creada con Flutter, diseñada para facilitar la conexión entre usuarios y profesionales técnicos de manera eficiente y segura.

Con un enfoque en la experiencia del usuario, **ServiExpress** permite explorar, agendar, monitorear y calificar servicios como mantenimiento, reparaciones o instalaciones desde la comodidad del celular. Nuestra plataforma busca digitalizar el acceso a servicios técnicos, centralizando toda la gestión en una sola app y generando oportunidades para profesionales independientes.

## Convenciones de Commits

Este proyecto sigue la convención de [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/).
</br>
[Ver guía de commits aquí](.github/COMMIT_CONVENTION.md)

## 📑 Tabla de Contenidos

- [Instalación](#instalación)
- [Uso](#uso)
- [Características](#características)
- [Arquitectura](#arquitectura)
- [Autores](#autores)
- [Estado del Proyecto](#estado-del-proyecto)
- [Licencia](#licencia)

---

## Instalación

### Requisitos

- Flutter >= 3.29.3
- Dart >= 3.7.2
- Firebase CLI (para emulador o deploy)

### Pasos

1. Clona el repositorio.
```bash
git clone https://github.com/sh4y0/serviexpress-app
````
2. Navega a la ruta generada.
```bash
cd serviexpress-app
````

3. Obten las dependecias.
```bash
flutter pub get
````

4. Instalar hook de commits

```bash
dart tool/install_hooks.dart
````

5. Prueba ServiExpress!

```bash
flutter run
````

---

## Uso

Una vez instalada la aplicación:

1. **Regístrate o inicia sesión** usando tu cuenta de Google o correo electrónico.
2. **Navega por las categorías** de servicios disponibles como electricidad, plomería, tecnología, entre otros.
3. **Consulta los perfiles profesionales**, revisando calificaciones y experiencia.
4. **Solicita un servicio**, elige fecha y hora, y espera la confirmación del profesional.
5. **Haz seguimiento** del servicio en tiempo real mediante notificaciones y estado del trabajo.
6. **Califica y deja tu opinión**, ayudando a otros usuarios a tomar mejores decisiones.

Toda la experiencia está pensada para ser rápida, transparente y segura.


---

## Características

* 📱 **Interfaz intuitiva:** basada en los principios de Material Design y diseñada para ser accesible a usuarios de todas las edades.
* 🔥 **Backend escalable:** gracias a Firebase, permite integrar funcionalidades avanzadas como notificaciones push, almacenamiento y analytics en tiempo real.
* 🔐 **Autenticación confiable:** compatible con login social (Google) y tradicional por correo electrónico, con validación y protección de sesiones.
* 📍 **Ubicación dinámica:** uso de servicios de geolocalización para encontrar profesionales cercanos y calcular tiempo estimado de llegada.
* 💬 **Sistema de mensajería interna:** permite coordinar detalles con el profesional sin salir de la app.
* 📊 **Sistema de reputación:** cada servicio puede ser calificado y comentado, fomentando la mejora continua y la confianza.


---

## Arquitectura

* **Frontend (Flutter + Riverpod):** Permite una gestión eficiente del estado, modularidad y pruebas. Usa widgets desacoplados y código reutilizable.
* **Backend (Firebase):** Se utilizan servicios como Authentication, Firestore, Cloud Functions, y Cloud Messaging, evitando la necesidad de un servidor propio.
* **Patrones de diseño:** Aplicamos principios de Clean Architecture y MVVM (Model-View-ViewModel) para separar responsabilidades y escalar con facilidad.

---

## Autores

<div align="center">
  <table cellspacing="50">
    <tr>
      <td align="center">
        <a href="https://github.com/elAsksito" target="_blank">
          <img src="https://github.com/elAsksito.png" width="100px;" alt="Allan Sagastegui"/><br />
          <sub><b>Allan Sagastegui</b></sub><br>
        </a><br />
        <a href="https://github.com/elAsksito" target="_blank">
          <img src="https://img.icons8.com/ios-filled/50/ffffff/github.png" width="30" style="margin-right: 8px;" />
        </a>
        <a href="https://www.linkedin.com/in/allan-sagastegui/" target="_blank">
          <img src="https://img.icons8.com/fluency/48/linkedin.png" width="32" style="margin-right: 8px;" />
        </a>
        <a href="https://www.instagram.com/_ask.dev/" target="_blank">
          <img src="https://img.icons8.com/fluency/48/instagram-new.png" width="32" />
        </a>
      </td>
      <td align="center">
        <a href="https://github.com/sh4y0" target="_blank">
          <img src="https://github.com/sh4y0.png" width="100px;" alt="Rodrigo Gutierrez"/><br />
          <sub><b>Rodrigo Gutierrez</b></sub><br>
        </a><br />
        <a href="https://github.com/sh4y0" target="_blank">
          <img src="https://img.icons8.com/ios-filled/50/ffffff/github.png" width="30" style="margin-right: 8px;" />
        </a>
        <a href="https://www.linkedin.com/in/jahir-gutierrez/" target="_blank">
          <img src="https://img.icons8.com/fluency/48/linkedin.png" width="32" style="margin-right: 8px;" />
        </a>
        <a href="https://www.instagram.com/rodri.9726" target="_blank">
          <img src="https://img.icons8.com/fluency/48/instagram-new.png" width="32" />
        </a>
      </td>
      <td align="center">
        <a href="https://github.com/Jefferson-Gonzales" target="_blank">
          <img src="https://github.com/Jefferson-Gonzales.png" width="100px;" alt="Jefferson Gonzales"/><br />
          <sub><b>Jefferson Gonzales</b></sub><br>
        </a><br />
        <a href="https://github.com/Jefferson-Gonzales" target="_blank">
          <img src="https://img.icons8.com/ios-filled/50/ffffff/github.png" width="30" style="margin-right: 8px;" />
        </a>
        <a href="https://www.linkedin.com/in/jefferson-gonzales-polo-621716310/" target="_blank">
          <img src="https://img.icons8.com/fluency/48/linkedin.png" width="32" style="margin-right: 8px;" />
        </a>
        <a href="#" target="_blank">
          <img src="https://img.icons8.com/fluency/48/instagram-new.png" width="32" />
        </a>
      </td>
    </tr>
  </table>

  <br/>
  <table cellspacing="50">
    <tr>
      <td align="center">
        <a href="https://github.com/JairGZZ" target="_blank">
          <img src="https://github.com/JairGZZ.png" width="100px;" alt="Jair Gonzalez"/><br />
          <sub><b>Jair Gonzalez</b></sub><br>
        </a><br />
        <a href="https://github.com/JairGZZ" target="_blank">
          <img src="https://img.icons8.com/ios-filled/50/ffffff/github.png" width="30" style="margin-right: 8px;" />
        </a>
        <a href="#" target="_blank">
          <img src="https://img.icons8.com/fluency/48/linkedin.png" width="32" style="margin-right: 8px;" />
        </a>
        <a href="https://www.instagram.com/jairgz_/" target="_blank">
          <img src="https://img.icons8.com/fluency/48/instagram-new.png" width="32" />
        </a>
      </td>
      <td align="center">
        <a href="https://github.com/https-michi" target="_blank">
          <img src="https://github.com/https-michi.png" width="100px;" alt="Miguel Sullcapuma"/><br />
          <sub><b>José Sullcapuma</b></sub><br>
        </a><br />
        <a href="https://github.com/https-michi" target="_blank">
          <img src="https://img.icons8.com/ios-filled/50/ffffff/github.png" width="30" style="margin-right: 8px;" />
        </a>
        <a href="https://www.linkedin.com/in/jose-sullca-b253b3318/" target="_blank">
          <img src="https://img.icons8.com/fluency/48/linkedin.png" width="32" style="margin-right: 8px;" />
        </a>
        <a href="https://www.instagram.com/miichi_u" target="_blank">
          <img src="https://img.icons8.com/fluency/48/instagram-new.png" width="32" />
        </a>
      </td>
    </tr>
  </table>
</div>

## Estado del Proyecto

> En proceso de refactorización.

---

## Licencia

Este proyecto está protegido bajo la cláusula de **"Todos los derechos reservados"**.

Queda estrictamente prohibido el uso, copia, modificación, redistribución o explotación comercial del código fuente o elementos de este proyecto sin autorización expresa de los propietarios de ServiExpress.

Para obtener permisos especiales o licencias de uso, por favor contacta directamente con los autores.

Para más información, contáctanos a: **[serviexpressdev@gmail.com](mailto:serviexpressdev@gmail.com)**

---
