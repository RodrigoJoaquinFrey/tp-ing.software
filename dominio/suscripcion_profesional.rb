class SuscripcionProfesional
  attr_reader :nombre, :limite_mensual

  LIMITE_MENSUAL_PROFESIONAL = 5
  def initialize
    @nombre = 'profesional'
    @limite_mensual = LIMITE_MENSUAL_PROFESIONAL
  end
end
