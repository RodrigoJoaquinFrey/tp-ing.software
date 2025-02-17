require_relative './suscripcion_gratuita'
require_relative './suscripcion_profesional'
require_relative './suscripcion_corporativa'
require_relative './errores'

class Suscripcion
  def crear_suscripcion(tipo_suscripcion)
    case tipo_suscripcion
    when 'gratuita'
      suscripcion = SuscripcionGratuita.new
    when 'profesional'
      suscripcion = SuscripcionProfesional.new
    when 'corporativa'
      suscripcion = SuscripcionCorporativa.new
    else
      raise DatoNoValido, 'tipo de suscripcion no valida'
    end
    suscripcion
  end
end
