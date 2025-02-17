class Oferta
  MAXIMO_CARACTERES_TITULO = 30
  MINIMO_CARACTERES_TITULO = 10
  MAXIMO_CARACTERES_DESCRIPCION = 200
  MINIMO_CARACTERES_DESCRIPCION = 10

  attr_reader :titulo, :descripcion, :usuario, :fecha_publicacion, :edad_minima, :edad_maxima

  def initialize(datos_oferta, usuario, fecha_publicacion, edad_minima = nil, edad_maxima = nil)
    validar_titulo(datos_oferta['titulo'])
    validar_descripcion(datos_oferta['descripcion'])
    validar_edades(edad_minima, edad_maxima)
    @titulo = datos_oferta['titulo']
    @descripcion = datos_oferta['descripcion']
    @usuario = usuario
    @fecha_publicacion = validar_fecha(fecha_publicacion)
    @edad_minima = edad_minima
    @edad_maxima = edad_maxima
  end

  private

  def validar_fecha(fecha)
    return Date.parse('1997-01-24') if fecha.nil?

    fecha
  end

  def validar_titulo(titulo)
    raise ParametroAusente, 'se necesita un titulo para publicar una oferta' if
    titulo.nil? || titulo.empty?

    raise CantidadDeCaracteresNoValida, 'el titulo debe tener entre 10 y 30 caracteres' if
    titulo.length < MINIMO_CARACTERES_TITULO || titulo.length > MAXIMO_CARACTERES_TITULO
  end

  def validar_descripcion(descripcion)
    raise ParametroAusente, 'se necesita una descripcion para publicar una oferta' if
    descripcion.nil? || descripcion.empty?

    raise CantidadDeCaracteresNoValida, 'la descripcion debe tener entre 10 y 200 caracteres' if
    descripcion.length < MINIMO_CARACTERES_DESCRIPCION ||
    descripcion.length > MAXIMO_CARACTERES_DESCRIPCION
  end

  def validar_edades(edad_minima, edad_maxima)
    if !edad_minima.nil?
      edad_minima = edad_minima.to_i
      raise DatoNoValido, 'La edad del postulante no puede ser menor a 18 años' if edad_minima < 18

      unless edad_maxima.nil?
        edad_maxima = edad_maxima.to_i
        if edad_maxima < edad_minima
          raise DatoNoValido,
                'La edad máxima no puede ser menor a la edad mínima'
        end
      end
    elsif !edad_maxima.nil?
      edad_maxima = edad_maxima.to_i
      raise DatoNoValido, 'La edad del postulante no puede ser menor a 18 años' if edad_maxima < 18
    end
  end
end
