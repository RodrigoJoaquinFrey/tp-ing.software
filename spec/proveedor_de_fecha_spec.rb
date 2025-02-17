require 'rspec'
require 'date'
require_relative '../adaptadores/proveedor_de_fecha'
require_relative '../dominio/excepciones'


describe 'Proovedor de fecha' do
  it 'parsear fecha, caso feliz' do
    resultado = ProveedorDeFecha.new.parsear_fecha('2018-12-18')
    expect(resultado).to eq Date.parse('2018-12-18')
  end

  it 'parsear fecha invalida devuelve FechaInvalida' do
    expect do
      ProveedorDeFecha.new.parsear_fecha('12 de octubre de 1898')
    end.to(raise_error(FechaInvalida))
  end

  it 'parsear fecha invalida devuelve FechaInvalida' do
    expect do
      ProveedorDeFecha.new.parsear_fecha('2018-62-58')
    end.to(raise_error(FechaInvalida))
  end

  it 'parsear fecha invalida con un 31 de febrero devuelve FechaInvalida' do
    expect do
      ProveedorDeFecha.new.parsear_fecha('2018-02-31')
    end.to(raise_error(FechaInvalida))
  end

  it 'parsear fecha invalida con un 31 de noviembre devuelve FechaInvalida' do
    expect do
      ProveedorDeFecha.new.parsear_fecha('2018-11-31')
    end.to(raise_error(FechaInvalida))
  end

  it 'obtener_fecha devuelve un objeto fecha con lo que se envie por variable de entorno' do
    ENV['FECHA_ACTUAL'] = '2023-01-10'

    resultado = ProveedorDeFecha.new.obtener_fecha
    expect(resultado).to eq Date.parse(ENV['FECHA_ACTUAL'])
  end
end
