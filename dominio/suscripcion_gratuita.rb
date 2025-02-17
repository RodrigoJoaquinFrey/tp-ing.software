class SuscripcionGratuita
  attr_reader :nombre, :limite_mensual

  LIMITE_MENSUAL_GRATUITO = 1
  def initialize
    @nombre = 'gratuita'
    @limite_mensual = LIMITE_MENSUAL_GRATUITO
  end
end
