require 'rspec'
require_relative '../dominio/usuario'
require_relative '../dominio/excepciones'

NOMBRE_USUARIO = 'Thorfinn'
APELLIDO_USUARIO = 'Thors'
MAIL_USUARIO = 'thorfinn@gmail.com'
FECHA_NACIMIENTO_USUARIO = '2002-20-02'

describe 'Usuario' do
  describe 'Inicializar usuario' do
    it 'Inicializar Usuario caso feliz' do
      resultado = Usuario.new(NOMBRE_USUARIO, APELLIDO_USUARIO, MAIL_USUARIO, FECHA_NACIMIENTO_USUARIO)
      expect(resultado.mail).to eq MAIL_USUARIO
      expect(resultado.nombre).to eq NOMBRE_USUARIO
      expect(resultado.apellido).to eq APELLIDO_USUARIO
    end

    it 'Deberia poder inicializar Usuario con nombre compuesto' do
      nombre_compuesto = NOMBRE_USUARIO + " " + NOMBRE_USUARIO
      resultado = Usuario.new(nombre_compuesto, APELLIDO_USUARIO, MAIL_USUARIO, FECHA_NACIMIENTO_USUARIO)
      expect(resultado.mail).to eq MAIL_USUARIO
      expect(resultado.nombre).to eq nombre_compuesto
      expect(resultado.apellido).to eq APELLIDO_USUARIO
    end

    it 'Deberia poder inicializar Usuario con apellido compuesto' do
      apellido_compuesto = APELLIDO_USUARIO + " " + APELLIDO_USUARIO
      resultado = Usuario.new(NOMBRE_USUARIO, apellido_compuesto, MAIL_USUARIO, FECHA_NACIMIENTO_USUARIO)
      expect(resultado.mail).to eq MAIL_USUARIO
      expect(resultado.nombre).to eq NOMBRE_USUARIO
      expect(resultado.apellido).to eq apellido_compuesto
    end

    it 'Inicializar Usuario con mail sin arroba' do
      expect do
        Usuario.new(NOMBRE_USUARIO, APELLIDO_USUARIO,'thorfinngmail.com', FECHA_NACIMIENTO_USUARIO)
        end.to(raise_error(EmailInvalidoError))
    end

    it 'Inicializar Usuario con nombre con menos de 3 caracteres' do
      expect do
        Usuario.new('ab', APELLIDO_USUARIO,MAIL_USUARIO, FECHA_NACIMIENTO_USUARIO)
      end.to(raise_error(NombreCortoError))
    end

    it 'Inicializar Usuario con nombre con caracteres invalidos' do
        expect do
          Usuario.new('ab!123', APELLIDO_USUARIO,MAIL_USUARIO, FECHA_NACIMIENTO_USUARIO)
        end.to(raise_error(NombreInvalidoError))
    end

    it 'Inicializar Usuario con apellido con menos de 3 caracteres' do
      expect do
        Usuario.new(NOMBRE_USUARIO, 'xd',MAIL_USUARIO, FECHA_NACIMIENTO_USUARIO)
      end.to(raise_error(ApellidoCortoError))
    end

    it 'Inicializar Usuario con apellido con caracteres invalidos' do
      expect do
        Usuario.new(NOMBRE_USUARIO, 'camionero77!!',MAIL_USUARIO, FECHA_NACIMIENTO_USUARIO)
      end.to(raise_error(ApellidoInvalidoError))
    end
  end
end

