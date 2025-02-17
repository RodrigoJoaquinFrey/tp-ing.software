require 'date'

class ProveedorDeFecha
  def ver_fecha
    return Date.parse(ENV['fecha']) if ENV['fecha']

    Date.today
  end
end
