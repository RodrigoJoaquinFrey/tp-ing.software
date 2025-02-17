api-empleos
===========
## Equipo Negro

### Integrantes:
- Luciana Germano 
- Sabrina Garcia
- Rodrigo Frey
- Leandro Gaitán

### Ambientes:
- Test: https://negro-test.onrender.com
- Prod: https://negro-prod.onrender.com

## Modo de uso

### Crear un usuario

Parámetros obligatorios:
- nombre_usuario: Mínimo 2 caracteres y máximo 30.
- apellido_usuario: Mínimo 2 caracteres y máximo 30.
- mail_usuario: Mínimo de 7 caracteres y un máximo de 100. Debe tener formato válido de email. No distingue mayúsculas y minúsculas. Debe ser único. No se puede registrar más de un usuario con el mismo mail.
- fecha_nacimiento_usuario: En formato AAAA-MM-DD. Debe ser una fecha válida. El usuario debe tener 18 o más años de edad.
- suscripcion: Puede ser
    - gratuita: Se permite publicar una oferta por mes 
    - profesional: Se permite publicar solo 5 ofertas por mes
    - corporativa: Se permite publicar ofertas ilimitadas por mes

#### Ejemplo:
`curl -X POST --data '{"nombre_usuario":"Nariyoshi", "apellido_usuario":"Miyagi", "mail_usuario":"mr_miyagi@karate.jp", "fecha_nacimiento_usuario":"1984-06-22", "suscripcion":"gratuita"}' https://negro-test.onrender.com/usuarios`

### Publicar una oferta

Parámetros obligatorios:
- titulo: Mínimo 10 caracteres, máximo 30.
- descripcion: Mínimo 10 caracteres, máximo 200.
- mail_usuario: Debe ser el mail de un usuario registrado en el sistema. No distingue mayúsculas y minúsculas. 

Parametros opcionales:
- edad_minima: No puede ser menor a 18 años. No puede ser más grande que la edad máxima si existiese.
- edad_maxima: No puede ser menor a 18 años. No puede ser más chica que la edad mínima si existiese.

#### Ejemplo:

`curl -X POST --data '{"titulo":"Aprendiz de Karate", "descripcion":"El candidato va a aprender técnicas de karate como: pulir y encerar. También a hacer la grulla", "edad_maxima":"30", "mail_usuario": "mr_miyagi@karate.jp"}' https://negro-test.onrender.com/ofertas`

### Ver todas las ofertas publicadas

Ver una lista de todas las ofertas publicadas en el sistema. Veo:
- ID
- Título
- Descripción de cada oferta.

#### Ejemplo:
`curl https://negro-test.onrender.com/ofertas`

### Ver el detalle de una oferta publicada

Ver detalles de una Oferta en particular con su ID. Se muestra:
- Título de la oferta
- Descripción de la oferta
- Edad mínima y/o máxima
- Datos del oferente:
    - Nombre
    - Apellido
    - Mail

#### Ejemplo:
`curl https://negro-test.com/ofertas/1`

### Editar una oferta publicada

Permite al creador de la oferta editar los siguientes parámetros de la oferta publicada:
- Descripción de la oferta
- Edad mínima o máxima (se pueden modificar, agregar o borrar.)

Es necesario pasar el mail del usuario que creo la oferta. No hace falta pasarle un título, ya que se conserva siempre el original.

#### Ejemplo:
`curl -X PUT --data '{ "descripcion":"El candidato va a aprender técnicas de karate como: pulir, encerar y pintar. También a hacer la grulla. No se admiten estudiantes del dojo Cobra Kai.", "mail_usuario": "mr_miyagi@karate.jp"}' https://negro-test.onrender.com/ofertas/1`