# frozen_string_literal: true

require 'rspec'
require_relative '../dominio/usuario'
require_relative '../dominio/oferta'
require_relative '../adaptadores/repositorio_ofertas_redis'
require_relative '../adaptadores/repositorio_usuarios_redis'

repo_ofertas = RepositorioOfertasRedis.new
repo_usuarios = RepositorioUsuariosRedis.new

def crearOfertaValida
  titulo = "Titulo de Oferta"
  descripcion = "Esto es la descripcion de la oferta. Tiene datos sobre la oferta."
  datos_personales = {"nombre" => 'nico', "apellido" => 'perez', "mail" => 'nico@gmail.com', "fecha_nacimiento" => '2004-04-25'}
  usuario = Usuario.new(datos_personales, suscripcion:'corporativa')
  datos_oferta =  { 'titulo' => titulo, 'descripcion' => descripcion }     
  fecha_publicacion = Date.parse('2024-11-08')
  oferta = Oferta.new(datos_oferta, usuario, fecha_publicacion)
end

describe 'RepositorioOfertasRedisSpec' do
  
  before(:each) do
    repo_ofertas.reset
    repo_usuarios.reset
  end

  describe 'guardar' do
    it 'guarda varias ofertas en el repositorio' do
      oferta = crearOfertaValida
      id_oferta = repo_ofertas.guardar(oferta)
      id_oferta2 = repo_ofertas.guardar(oferta)
      expect(id_oferta).to eq 1
      expect(id_oferta2).to eq 2
      expect(repo_ofertas.size).to eq 2
    end
  end

  describe 'encontrar ofertas' do
    it 'encuentra una oferta en el repositorio y devuelve los datos de la misma' do
      titulo = "Titulo de Oferta"
      descripcion = "Esto es la descripcion de la oferta. Tiene datos sobre la oferta."

      datos_personales = { "nombre" => 'nico', "apellido" => 'perez', "mail" => 'nico@gmail.com', "fecha_nacimiento" => '2004-04-25' }
      usuario = Usuario.new(datos_personales, suscripcion:'corporativa')
      id_usuario = repo_usuarios.guardar(usuario)

      datos_oferta =  { 'titulo' => titulo, 'descripcion' => descripcion }     
      fecha_publicacion = Date.parse('2024-11-08')
      oferta = Oferta.new(datos_oferta, usuario, fecha_publicacion, 25, nil)
      id_oferta = repo_ofertas.guardar(oferta)
      oferta_encontrada = repo_ofertas.encontrar(id_oferta)

      expect(oferta_encontrada.titulo).to eq 'Titulo de Oferta'
      expect(oferta_encontrada.usuario.nombre).to eq 'nico'
      expect(oferta_encontrada.descripcion).to eq "Esto es la descripcion de la oferta. Tiene datos sobre la oferta."
      expect(oferta_encontrada.edad_minima). to eq 25

      expect(repo_ofertas.size).to eq 1
    end

    it 'lista todas las ofertas publicadas' do
      oferta = crearOfertaValida
      id_oferta = repo_ofertas.guardar(oferta)
      id_oferta2 = repo_ofertas.guardar(oferta)
      ofertas = repo_ofertas.listar_todas
      expect(ofertas.size).to eq 2
      expect(ofertas[0][1]['titulo']).to eq "Titulo de Oferta"
      expect(ofertas[0][1]['descripcion']).to eq "Esto es la descripcion de la oferta. Tiene datos sobre la oferta."
      expect(ofertas[0][1]['id_usuario']).to eq "nico@gmail.com"

      expect(ofertas[1][2]['titulo']).to eq "Titulo de Oferta"
      expect(ofertas[1][2]['descripcion']).to eq "Esto es la descripcion de la oferta. Tiene datos sobre la oferta."
      expect(ofertas[1][2]['id_usuario']).to eq "nico@gmail.com"
    end
  end

  describe 'actualizacion ofertas' do
    it 'guardo una oferta, la actualizo en el repositorio y devuelve los datos de la misma' do
      titulo = "Titulo de Oferta"
      descripcion = "Esto es la descripcion de la oferta. Tiene datos sobre la oferta."
      datos_personales = {"nombre" => 'nico', "apellido" => 'perez', "mail" => 'nico@gmail.com', "fecha_nacimiento" => '2004-04-25'}
      usuario = Usuario.new(datos_personales, suscripcion:'corporativa')
      id_usuario = repo_usuarios.guardar(usuario)

      datos_oferta =  { 'titulo' => titulo, 'descripcion' => descripcion }     
      fecha_publicacion = Date.parse('2024-11-08')
      oferta = Oferta.new(datos_oferta, usuario, fecha_publicacion)
      id_oferta = repo_ofertas.guardar(oferta)

      descripcion_actualizada = "Esto es la descripcion de la oferta actualizada. Tiene datos sobre la oferta actualizada."
      datos_oferta_actualizada = { 'titulo' => titulo, 'descripcion' => descripcion_actualizada } 
      
      oferta_actualizada = Oferta.new(datos_oferta_actualizada, usuario, fecha_publicacion)
      id_oferta_actualizada = repo_ofertas.guardar_actualizacion(oferta_actualizada, id_oferta)

      oferta_encontrada = repo_ofertas.encontrar(id_oferta_actualizada)

      expect(oferta_encontrada.titulo).to eq 'Titulo de Oferta'
      expect(oferta_encontrada.descripcion).to eq "Esto es la descripcion de la oferta actualizada. Tiene datos sobre la oferta actualizada."
      expect(oferta_encontrada.fecha_publicacion).to eq '2024-11-08'
      expect(repo_ofertas.size).to eq 1
    end
  end
  
  describe 'encontrar todas las ofertas de un usuario' do
    it 'lista todas las ofertas de un usuario' do
      titulo = "Titulo de Oferta"
      descripcion = "Esto es la descripcion de la oferta. Tiene datos sobre la oferta."
      
      datos_personales = {"nombre" => 'nico', "apellido" => 'perez', "mail" => 'nico@gmail.com', "fecha_nacimiento" => '2004-04-25'}
      usuario = Usuario.new(datos_personales, suscripcion:'corporativa')
      id_usuario = repo_usuarios.guardar(usuario)

      datos_oferta =  { 'titulo' => titulo, 'descripcion' => descripcion }
      fecha_publicacion = Date.parse('2024-11-08')

      oferta = Oferta.new(datos_oferta, usuario, fecha_publicacion)
      id_oferta = repo_ofertas.guardar(oferta)

      datos_personales2 = {"nombre" => 'luciana', "apellido" => 'germano', "mail" => 'luli@gmail.com', "fecha_nacimiento" => '2000-03-04'}
      usuario2 = Usuario.new(datos_personales2, suscripcion:'gratuita')
      id_usuario2 = repo_usuarios.guardar(usuario2)
      oferta2 = Oferta.new(datos_oferta, usuario2, fecha_publicacion)
      id_oferta2 = repo_ofertas.guardar(oferta2)
      
      ofertas = repo_ofertas.encontrar_todas_id(id_usuario)
      expect(ofertas.size).to eq 1
    end
  end
end
