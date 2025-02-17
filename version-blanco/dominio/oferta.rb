require_relative './excepciones'

class Oferta
  attr_reader :titulo, :descripcion, :mail, :mails_de_postulantes, :remuneracion_ofrecida, :id, :ubicacion_oferta, :edad_minima_postulacion, :etiquetas

  REGEX_TITULO_MAXIMO = /^.{1,30}$/
  REGEX_UBICACION_EXTENSION = /^.{3,50}$/
  REGEX_ETIQUETA_EXTENSION = /^.{3,20}$/

  def initialize(titulo, descripcion, mail, parametros_opcionales = {})
    parametros_opcionales = parametros_opcionales.transform_keys(&:to_sym)

    validar_parametros(titulo, descripcion, parametros_opcionales)

    @id                       = parametros_opcionales[:id_oferta]
    @titulo                   = titulo
    @descripcion              = descripcion
    @mail                     = mail
    @mails_de_postulantes     = parametros_opcionales.fetch(:mails_de_postulantes, [])
    @remuneracion_ofrecida    = parametros_opcionales[:remuneracion_ofrecida]
    @ubicacion_oferta         = parametros_opcionales[:ubicacion_oferta]
    @edad_minima_postulacion  = parametros_opcionales[:edad_minima_postulacion]
    @etiquetas                = parametros_opcionales[:etiquetas]
  end

  def agregar_mail_postulante(mail_postulante)
    raise MailYaPostuladoError if @mails_de_postulantes.include? mail_postulante

    @mails_de_postulantes.append(mail_postulante)
  end

  def validar_postulacion(usuario, oferta, proveedor_fecha)
    fecha_hoy = proveedor_fecha.obtener_fecha
    edad_usuario =  fecha_hoy.year - usuario.fecha_nacimiento.year
    edad_usuario -= 1 if fecha_hoy < Date.new(fecha_hoy.year, usuario.fecha_nacimiento.month,
                                              usuario.fecha_nacimiento.day)

    return unless oferta.edad_minima_postulacion && oferta.edad_minima_postulacion > edad_usuario

    raise NoCumpleEdadMinimaError, oferta.edad_minima_postulacion
  end

  private

  def validar_parametros(titulo, descripcion, params)
    validar_titulo(titulo)
    validar_descripcion(descripcion)
    validar_remuneracion(params[:remuneracion_ofrecida])
    validar_ubicacion(params[:ubicacion_oferta])
    validar_edad_minima(params[:edad_minima_postulacion])
    validar_etiquetas(params[:etiquetas])
  end

  def validar_titulo(titulo)
    raise TituloVacioError if titulo.strip.empty?
    raise TituloExtensoError unless titulo.match?(REGEX_TITULO_MAXIMO)
  end

  def validar_descripcion(descripcion)
    raise DescripcionVaciaError if descripcion.strip.empty?
  end

  def validar_remuneracion(remuneracion)
    return unless remuneracion
    return if remuneracion.is_a?(Integer) && remuneracion.positive?

    raise RemuneracionInvalidaError
  end

  def validar_ubicacion(ubicacion)
    return unless ubicacion
    return if ubicacion.size.between?(3, 50)

    raise UbicacionExtensionError
  end

  def validar_edad_minima(edad_minima)
    return unless edad_minima
    return if edad_minima.is_a?(Integer) && (0..99).cover?(edad_minima)

    raise EdadMinimaInvalidaError
  end

  def validar_etiquetas(etiquetas)
    return unless etiquetas

    raise EtiquetasCantidadError unless etiquetas.size.between?(0, 5)

    etiquetas.each do |etiqueta|
      raise EtiquetaExtensionError unless etiqueta.match(REGEX_ETIQUETA_EXTENSION)
    end

    raise EtiquetasRepetidasError unless etiquetas.uniq!.nil?
  end
end
