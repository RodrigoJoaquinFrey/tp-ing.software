class EmailInvalidoError < StandardError
  def initialize(msg = 'El mail no es valido. Formato esperado: ejemplo@dominio.com')
    super
  end
end

class NombreCortoError < StandardError
  def initialize(msg = 'El nombre debe tener un mínimo de 3 caracteres')
    super
  end
end

class NombreInvalidoError < StandardError
  def initialize(msg = 'Nombre con caracteres invalidos')
    super
  end
end

class ApellidoCortoError < StandardError
  def initialize(msg = 'El apellido debe tener un mínimo de 3 caracteres')
    super
  end
end

class ApellidoInvalidoError < StandardError
  def initialize(msg = 'Apellido con caracteres invalidos')
    super
  end
end

class TituloVacioError < StandardError
  def initialize(msg = 'El titulo no puede estar vacio o ser solo espacios')
    super
  end
end

class TituloExtensoError < StandardError
  def initialize(msg = 'El titulo debe tener un maximo de 30 caracteres')
    super
  end
end

class DescripcionVaciaError < StandardError
  def initialize(msg = 'La descripcion no puede estar vacia o ser solo espacios')
    super
  end
end

class UsuarioNoRegistrado < StandardError
  def initialize(msg = 'Usuario no registrado')
    super
  end
end

class MailYaPostuladoError < StandardError
  def initialize(msg = 'El mail ya se encuentra postulado a la oferta')
    super
  end
end

class IdOfertaInexistenteError < StandardError
  def initialize(msg = 'El id ingresado no se encuentra asociado a ninguna oferta')
    super
  end
end

class RemuneracionInvalidaError < StandardError
  def initialize(msg = 'La remuneracion debe ser un numero entero positivo')
    super
  end
end

class TituloABuscarInvalido < StandardError
  def initialize(msg = 'El titulo a buscar debe ser mayor a 3 caracteres.')
    super
  end
end

class FechaInvalida < StandardError
  def initialize(msg = 'Fecha invalida. Formato YYYY-MM-DD')
    super
  end
end

class UbicacionExtensionError < StandardError
  def initialize(msg = 'La ubicación debe ser mayor a 3 caracteres y menor a 50')
    super
  end
end

class EdadMinimaInvalidaError < StandardError
  def initialize(msg = 'El campo de edad mínima debe ser un entero entre 0 y 99')
    super
  end
end

class NoCumpleEdadMinimaError < StandardError
  def initialize(edad_minima)
    msg = "La edad mínima para postularse es #{edad_minima}"
    super(msg)
  end
end

class EtiquetaExtensionError < StandardError
  def initialize(msg = 'Cada etiqueta debe tener entre 3 y 20 caracteres')
    super
  end
end

class EtiquetasCantidadError < StandardError
  def initialize(msg = 'No se aceptan mas de 5 etiquetas')
    super
  end
end

class EtiquetasRepetidasError < StandardError
  def initialize(msg = 'No se aceptan etiquetas repetidas')
    super
  end
end
