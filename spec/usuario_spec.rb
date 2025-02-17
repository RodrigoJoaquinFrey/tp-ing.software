require 'rspec'
require_relative '../dominio/usuario'

describe 'Usuario' do
  it 'se inicializa un usuario con nombre, apellido, mail y fecha de nacimiento' do
    nombre = 'nico'
    apellido = 'perez'
    mail = 'nico@gmail.com'
    fecha_nacimiento = '1999-01-28'
    datos_personales = {"nombre" => nombre, "apellido" => apellido, "mail" => mail, "fecha_nacimiento" => fecha_nacimiento}
    usuario = Usuario.new(datos_personales)
    expect(usuario.nombre).to eq "nico"
    expect(usuario.apellido).to eq "perez"
    expect(usuario.mail).to eq "nico@gmail.com"
    expect(usuario.fecha_nacimiento).to eq "1999-01-28"
  end

  describe 'Validaciones nombre' do
    it 'deberia devolver error si se pasa un nombre vacio para registrarse' do
      nombre = ''
      apellido = 'perez'
      mail = 'nico@gmail.com'
      fecha_nacimiento = '1999-01-28'
      datos_personales = {"nombre" => nombre, "apellido" => apellido, "mail" => mail, "fecha_nacimiento" => fecha_nacimiento}
      expect{ Usuario.new(datos_personales) }.to raise_error(ParametroAusente)
    end

    it 'deberia devolver error si no se pasa un nombre para registrarse' do
      nombre = nil
      apellido = 'perez'
      mail = 'nico@gmail.com'
      fecha_nacimiento = '1999-01-28'
      datos_personales = {"nombre" => nombre, "apellido" => apellido, "mail" => mail, "fecha_nacimiento" => fecha_nacimiento}
      expect{ Usuario.new(datos_personales) }.to raise_error(ParametroAusente)
    end

    it 'deberia devolver error si se pasa de 30 caracteres en el nombre al registrarse' do
      nombre = 'juannnnnnnnnnnnnnnnnnnnnnnnnnnn'
      apellido = 'perez'
      mail = 'nico@gmail.com'
      fecha_nacimiento = '1999-01-28'
      datos_personales = {"nombre" => nombre, "apellido" => apellido, "mail" => mail, "fecha_nacimiento" => fecha_nacimiento}
      expect{ Usuario.new(datos_personales) }.to raise_error(CantidadDeCaracteresNoValida)
    end
  end

  describe 'Validaciones apellido' do
    it 'deberia devolver error si se pasa un apellido vacio para registrarse' do
      nombre = 'juan'
      apellido = ''
      mail = 'nico@gmail.com'
      fecha_nacimiento = '1999-01-28'
      datos_personales = {"nombre" => nombre, "apellido" => apellido, "mail" => mail, "fecha_nacimiento" => fecha_nacimiento}
      expect{ Usuario.new(datos_personales) }.to raise_error(ParametroAusente)
    end

    it 'deberia devolver error si no se pasa un apellido para registrarse' do
      nombre = 'juan'
      apellido = nil
      mail = 'nico@gmail.com'
      fecha_nacimiento = '1999-01-28'
      datos_personales = {"nombre" => nombre, "apellido" => apellido, "mail" => mail, "fecha_nacimiento" => fecha_nacimiento}
      expect{ Usuario.new(datos_personales) }.to raise_error(ParametroAusente)
    end

    it 'deberia devolver error si se pasa de 30 caracteres en el apellido al registrarse' do
      nombre = 'juan'
      apellido = 'perezzzzzzzzzzzzzzzzzzzzzzzzzzz'
      mail = 'nico@gmail.com'
      fecha_nacimiento = '1999-01-28'
      datos_personales = {"nombre" => nombre, "apellido" => apellido, "mail" => mail, "fecha_nacimiento" => fecha_nacimiento}
      expect{ Usuario.new(datos_personales) }.to raise_error(CantidadDeCaracteresNoValida)
    end
  end

  describe 'Validaciones mail' do
    it 'al crear un usuario, si se pasa un mail en mayusculas se deberia guardar el mismo en minusculas' do
      nombre = 'juan'
      apellido = 'perez'
      mail = 'JUAN@GMAIL.COM'
      fecha_nacimiento = '1999-01-28'
      datos_personales = {"nombre" => nombre, "apellido" => apellido, "mail" => mail, "fecha_nacimiento" => fecha_nacimiento}
      usuario = Usuario.new(datos_personales)
      expect(usuario.mail).to eq "juan@gmail.com"
    end

    it 'deberia devolver error si se pasa un mail vacio para registrarse' do
      nombre = 'juan'
      apellido = 'perez'
      mail = ''
      fecha_nacimiento = '1999-01-28'
      datos_personales = {"nombre" => nombre, "apellido" => apellido, "mail" => mail, "fecha_nacimiento" => fecha_nacimiento}
      expect{ Usuario.new(datos_personales) }.to raise_error(ParametroAusente)
    end

    it 'deberia devolver error si no se pasa un mail para registrarse' do
      nombre = 'juan'
      apellido = 'perez'
      mail = nil
      fecha_nacimiento = '1999-01-28'
      datos_personales = {"nombre" => nombre, "apellido" => apellido, "mail" => mail, "fecha_nacimiento" => fecha_nacimiento}
      expect{ Usuario.new(datos_personales) }.to raise_error(ParametroAusente)
    end

    it 'deberia devolver error si se pasa de 100 caracteres en el mail al registrarse' do
      nombre = 'juan'
      apellido = 'perez'
      mail = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx@gmail.com'
      fecha_nacimiento = '1999-01-28'
      datos_personales = {"nombre" => nombre, "apellido" => apellido, "mail" => mail, "fecha_nacimiento" => fecha_nacimiento}
      expect{ Usuario.new(datos_personales) }.to raise_error(CantidadDeCaracteresNoValida)
    end

    it 'deberia devolver error si los caracteres en el mail al registrarse son menores a 7' do
      nombre = 'juan'
      apellido = 'perez'
      mail = 'x@xx.a'
      fecha_nacimiento = '1999-01-28'
      datos_personales = {"nombre" => nombre, "apellido" => apellido, "mail" => mail, "fecha_nacimiento" => fecha_nacimiento}
      expect{ Usuario.new(datos_personales) }.to raise_error(CantidadDeCaracteresNoValida)
    end

    it 'deberia devolver error si el formato de mail no es valido al registrarse' do
      nombre = 'juan'
      apellido = 'perez'
      mail = 'pablo22.edu.ar'
      fecha_nacimiento = '1999-01-28'
      datos_personales = {"nombre" => nombre, "apellido" => apellido, "mail" => mail, "fecha_nacimiento" => fecha_nacimiento}
      expect{ Usuario.new(datos_personales) }.to raise_error(FormatoNoValido)
    end
  end

  describe 'Validaciones fecha' do
    it 'deberia devolver error si se pasa una fecha de nacimiento vacia para registrarse' do
      nombre = 'nicolas'
      apellido = 'perez'
      mail = 'nico@gmail.com'
      fecha_nacimiento = ''
      datos_personales = {"nombre" => nombre, "apellido" => apellido, "mail" => mail, "fecha_nacimiento" => fecha_nacimiento}
      expect{ Usuario.new(datos_personales) }.to raise_error(ParametroAusente)
    end

    it 'deberia devolver error si no se pasa una fecha de nacimiento para registrarse' do
      nombre = 'nicolas'
      apellido = 'perez'
      mail = 'nico@gmail.com'
      fecha_nacimiento = nil
      datos_personales = {"nombre" => nombre, "apellido" => apellido, "mail" => mail, "fecha_nacimiento" => fecha_nacimiento}
      expect{ Usuario.new(datos_personales) }.to raise_error(ParametroAusente)
    end
    
    it 'deberia devolver error si se pasa una fecha de nacimiento con formato no valido' do
      nombre = 'nicolas'
      apellido = 'perez'
      mail = 'nico@gmail.com'
      fecha_nacimiento = "20-02-2000"
      datos_personales = {"nombre" => nombre, "apellido" => apellido, "mail" => mail, "fecha_nacimiento" => fecha_nacimiento}
      expect{ Usuario.new(datos_personales) }.to raise_error(FormatoNoValido)
    end

    it 'deberia devolver error si la fecha de nacimiento no corresponde a una fecha valida' do
      nombre = 'nicolas'
      apellido = 'perez'
      mail = 'nico@gmail.com'
      fecha_nacimiento = "2000-15-10"
      datos_personales = {"nombre" => nombre, "apellido" => apellido, "mail" => mail, "fecha_nacimiento" => fecha_nacimiento}
      expect{ Usuario.new(datos_personales) }.to raise_error(DatoNoValido)
    end

    it 'deberia devolver error si la edad segun la fecha de nacimiento es menor a 18 años' do
      nombre = 'nicolas'
      apellido = 'perez'
      mail = 'nico@gmail.com'
      fecha_nacimiento = "2007-11-02"
      datos_personales = {"nombre" => nombre, "apellido" => apellido, "mail" => mail, "fecha_nacimiento" => fecha_nacimiento}
      expect{ Usuario.new(datos_personales, fecha_actual:Date.parse("2024-11-02")) }.to raise_error(DatoNoValido)
    end
  end

  describe 'Tipos de suscripciones' do
    it 'se inicializa un usuario con tipo de suscripcion gratuita por default' do
      nombre = 'nico'
      apellido = 'perez'
      mail = 'nico@gmail.com'
      fecha_nacimiento = '1999-01-28'
      datos_personales = {"nombre" => nombre, "apellido" => apellido, "mail" => mail, "fecha_nacimiento" => fecha_nacimiento}
      suscripcion = 'gratuita'
      usuario = Usuario.new(datos_personales)
      expect(usuario.suscripcion).is_a? SuscripcionGratuita
    end

    it 'se inicializa un usuario con tipo de suscripcion gratuita' do
      nombre = 'nico'
      apellido = 'perez'
      mail = 'nico@gmail.com'
      fecha_nacimiento = '1999-01-28'
      datos_personales = {"nombre" => nombre, "apellido" => apellido, "mail" => mail, "fecha_nacimiento" => fecha_nacimiento}
      suscripcion = 'gratuita'
      usuario = Usuario.new(datos_personales, suscripcion:suscripcion)
      expect(usuario.suscripcion).is_a? SuscripcionGratuita
    end

    it 'se inicializa un usuario con tipo de suscripcion profesional' do
      nombre = 'nico'
      apellido = 'perez'
      mail = 'nico@gmail.com'
      fecha_nacimiento = '1999-01-28'
      datos_personales = {"nombre" => nombre, "apellido" => apellido, "mail" => mail, "fecha_nacimiento" => fecha_nacimiento}
      suscripcion = 'profesional'
      usuario = Usuario.new(datos_personales, suscripcion:suscripcion)
      expect(usuario.suscripcion).is_a? SuscripcionProfesional
    end

    it 'se inicializa un usuario con tipo de suscripcion corporativa' do
      nombre = 'nico'
      apellido = 'perez'
      mail = 'nico@gmail.com'
      fecha_nacimiento = '1999-01-28'
      datos_personales = {"nombre" => nombre, "apellido" => apellido, "mail" => mail, "fecha_nacimiento" => fecha_nacimiento}
      suscripcion = 'corporativa'
      usuario = Usuario.new(datos_personales, suscripcion:suscripcion)
      expect(usuario.suscripcion).is_a? SuscripcionCorporativa
    end
  end
end
