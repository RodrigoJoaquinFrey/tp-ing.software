require 'date'
class ProveedorDeFecha
  # Explicación del regex:
  #
  # ^(1|2)\d{3}: El año debe comenzar con 1 o 2 (mileno válido), seguido de tres dígitos.
  #  -(0[1-9]|1[0-2]): El mes debe ser del 01 al 12.
  #  -(0[1-9]|[12]\d|3[01])$: El día debe ser del 01 al 31.

  REGEX_FECHA = /^(1|2)\d{3}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01])$/
  def parsear_fecha(fecha)
    raise FechaInvalida unless fecha.match?(REGEX_FECHA)

    begin
      Date.parse(fecha)
    rescue ArgumentError
      raise FechaInvalida
    end
  end

  def obtener_fecha
    return parsear_fecha(ENV['FECHA_ACTUAL']) if ENV['FECHA_ACTUAL']

    Date.today
  end
end
