class SuscripcionCorporativa
  attr_reader :nombre, :limite_mensual

  LIMITE_MENSUAL_CORPORATIVO = Float::INFINITY
  def initialize
    @nombre = 'corporativa'
    @limite_mensual = LIMITE_MENSUAL_CORPORATIVO
  end
end
