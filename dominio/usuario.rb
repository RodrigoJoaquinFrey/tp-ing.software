require 'date'
require_relative './suscripcion'
require_relative './errores'

class Usuario
  MINIMO_CARACTERES = 2
  MAXIMO_CARACTERES = 30
  MAXIMO_CARACTERES_MAIL = 100
  MINIMO_CARACTERES_MAIL = 7
  FORMATO_MAIL_VALIDO = /\A[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9\-.]+\z/
  FORMATO_FECHA_VALIDO = /\A\d{4}-\d{2}-\d{2}\Z/
  EDAD_MINIMA_EN_ANIOS = 18
  MESES_POR_ANIO = 12

  attr_reader :mail, :nombre, :apellido, :fecha_nacimiento, :suscripcion

  def initialize(datos_personales, fecha_actual: nil, suscripcion: 'gratuita')
    validar_nombre(datos_personales['nombre'])
    validar_nombre(datos_personales['apellido'])
    validar_mail(datos_personales['mail'])
    validar_fecha_nacimiento(datos_personales['fecha_nacimiento'], fecha_actual)

    @nombre = datos_personales['nombre']
    @apellido = datos_personales['apellido']
    @mail = datos_personales['mail'].downcase
    @fecha_nacimiento = datos_personales['fecha_nacimiento']
    @suscripcion = Suscripcion.new.crear_suscripcion(suscripcion)
  end

  def obtener_id
    mail
  end

  private

  def validar_nombre(nombre)
    raise ParametroAusente, 'se necesitan nombre y apellido para registrar el usuario' if
    nombre.nil? || nombre.empty?
    return unless nombre.length < MINIMO_CARACTERES || nombre.length > MAXIMO_CARACTERES

    raise CantidadDeCaracteresNoValida,
          'tanto el nombre como el apellido deben tener entre 2 y 30 caracteres'
  end

  def validar_mail(mail)
    raise ParametroAusente, 'se necesita un mail para registrar el usuario' if
    mail.nil? || mail.empty?
    raise FormatoNoValido, 'formato de mail invalido' unless mail.match?(FORMATO_MAIL_VALIDO)
    return unless mail.length < MINIMO_CARACTERES_MAIL || mail.length > MAXIMO_CARACTERES_MAIL

    raise CantidadDeCaracteresNoValida, 'el mail debe tener entre 7 y 100 caracteres'
  end

  def validar_fecha_nacimiento(fecha_nacimiento, fecha_actual)
    raise ParametroAusente, 'se necesita una fecha de nacimiento para registrar el usuario' if
    fecha_nacimiento.nil? || fecha_nacimiento.empty?

    unless fecha_nacimiento.match?(FORMATO_FECHA_VALIDO)
      raise FormatoNoValido,
            'fecha de nacimiento no valida, formato debe ser AAAA-MM-DD'
    end

    begin
      Date.parse(fecha_nacimiento)
    rescue ArgumentError
      raise DatoNoValido, 'fecha de nacimiento no corresponde a una fecha valida'
    end

    if !fecha_actual.nil? &&
       Date.parse(fecha_nacimiento) > (fecha_actual << EDAD_MINIMA_EN_ANIOS * MESES_POR_ANIO)
      raise DatoNoValido,
            'No se puede registrar un usuario menor de edad'
    end

    nil
  end
end
