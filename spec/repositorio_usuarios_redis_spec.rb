# frozen_string_literal: true

require 'rspec'
require_relative '../dominio/usuario'
require_relative '../adaptadores/repositorio_usuarios_redis'


repo = RepositorioUsuariosRedis.new

describe 'RepositorioUsuariosRedisSpec' do
  before(:each) do
    repo.reset
  end

  describe 'guardar' do
    it 'guarda un usuario en el repositorio' do
      datos_personales = {"nombre" => 'nico', "apellido" => 'perez', "mail" => 'nico@gmail.com', "fecha_nacimiento" => '1997-01-24'}
      usuario = Usuario.new(datos_personales)
      id =  repo.guardar(usuario)
      expect(id).to eq 'nico@gmail.com'
      expect(repo.size).to eq 1
    end
  end
  describe 'encontrar' do
    it 'deberia encontrar un usuario en el repositorio con su mail' do
      datos_personales = {"nombre" => 'nico', "apellido" => 'perez', "mail" => 'nico@gmail.com', "fecha_nacimiento" => '1997-01-24'}
      usuario = Usuario.new(datos_personales)
      id =  repo.guardar(usuario)

      usuario_encontrado = repo.encontrar('nico@gmail.com')
      expect(usuario_encontrado).not_to be_nil
      expect(usuario_encontrado.nombre).to eq 'nico'
    end

    it 'deberia encontrar un usuario en el repositorio con su mail y se crea con la suscripcion correcta' do
      datos_personales = {"nombre" => 'nico', "apellido" => 'perez', "mail" => 'nico@gmail.com', "fecha_nacimiento" => '1997-01-24'}
      usuario = Usuario.new(datos_personales, suscripcion:'profesional')
      id =  repo.guardar(usuario)

      usuario_encontrado = repo.encontrar('nico@gmail.com')
      expect(usuario_encontrado).not_to be_nil
      expect(usuario_encontrado.suscripcion).is_a? SuscripcionProfesional
    end
  end
end
