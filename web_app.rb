require 'sinatra'
require 'sinatra/json'

require_relative './dominio/sistema_empleos'
require_relative './adaptadores/repositorio_usuarios_redis'
require_relative './adaptadores/repositorio_ofertas_redis'
require_relative './adaptadores/proveedor_de_fecha'

configure do
  repositorio_usuarios = RepositorioUsuariosRedis.new
  repositorio_ofertas = RepositorioOfertasRedis.new
  proveedor_de_fecha = ProveedorDeFecha.new
  set :sistema_empleos,
      SistemaEmpleos.new(repositorio_usuarios, repositorio_ofertas, proveedor_de_fecha)
  set :show_exceptions, false
end

before do
  if !request.body.nil? && request.body.size.positive?
    request.body.rewind
    @params = JSON.parse(request.body.read, symbolize_names: true)
  end
end

def sistema
  settings.sistema_empleos
end

get '/' do
  json({ mensaje: 'sistema empleos negro' })
end

post '/reset' do
  sistema.reset
end

post '/usuarios' do
  nombre = params[:nombre_usuario]
  apellido = params[:apellido_usuario]
  mail = params[:mail_usuario]
  fecha_nacimiento_usuario = params[:fecha_nacimiento_usuario]
  suscripcion = params[:suscripcion]
  id_usuario = sistema.registrar_usuario(nombre, apellido, mail, fecha_nacimiento_usuario,
                                         suscripcion)
  json({ id_usuario: })
rescue ParametroAusente, CantidadDeCaracteresNoValida,
       FormatoNoValido, DatoNoValido, MailYaRegistrado => e
  status 400
  json({ 'mensaje' => e.message})
end

post '/ofertas' do
  titulo = params[:titulo]
  descripcion = params[:descripcion]
  mail_usuario = params[:mail_usuario]
  edad_minima = params[:edad_minima]
  edad_maxima = params[:edad_maxima]
  id_oferta = sistema.registrar_oferta(titulo, descripcion, mail_usuario, edad_minima, edad_maxima)
  json({ id_oferta: })
rescue ParametroAusente, UsuarioNoRegistrado, CantidadDeCaracteresNoValida,
       DatoNoValido, LimiteDePublicacionesAlcanzado => e
  status 400
  json({ 'mensaje' => e.message})
end

get '/ofertas/:id_oferta' do
  id_oferta = params['id_oferta']
  oferta = sistema.consultar_oferta(id_oferta)
  mostrar_una_oferta(oferta)
rescue OfertaNoEncontrada => e
  status 404
  json({ 'mensaje' => e.message})
end

get '/ofertas' do
  ofertas = sistema.listar_todas_las_ofertas
  mostrar_todas_las_ofertas(ofertas)
end

put '/ofertas/:id_oferta' do
  id_oferta = params['id_oferta'].to_i
  params[:titulo]
  descripcion = params[:descripcion]
  mail_usuario = params[:mail_usuario]

  opcionales = {
    edad_minima: params[:edad_minima],
    edad_maxima: params[:edad_maxima]
  }

  id_oferta_actualizada = sistema.actualizar_oferta(descripcion, mail_usuario, id_oferta,
                                                    opcionales)
  json({ id_oferta_actualizada: })
rescue MailNoAutorizado, CantidadDeCaracteresNoValida, OfertaNoEncontrada, DatoNoValido => e
  status 400
  json({ 'mensaje' => e.message})
rescue ParametroAusente
  status 400
  json({ 'mensaje' => 'Se necesita una descripcion y un mail para actualizar una oferta'})
end

def mostrar_todas_las_ofertas(ofertas)
  lista_redis = []
  (0..ofertas.size - 1).each do |numero_de_oferta|
    oferta = {ID: numero_de_oferta + 1,
              titulo_oferta: ofertas[numero_de_oferta][numero_de_oferta + 1]['titulo'],
              descripcion_oferta: ofertas[numero_de_oferta][numero_de_oferta + 1]['descripcion']}
    lista_redis.append(oferta)
  end
  json(lista_redis)
end

def mostrar_una_oferta(oferta)
  datos_oferta = {
    'titulo' => oferta.titulo,
    'descripcion' => oferta.descripcion,
    'nombre_usuario' => oferta.usuario.nombre,
    'apellido_usuario' => oferta.usuario.apellido
  }

  datos_oferta = edades_min_y_max?(datos_oferta, oferta.edad_minima, oferta.edad_maxima)

  datos_oferta['mail_usuario'] = oferta.usuario.mail

  json(datos_oferta)
end

def edades_min_y_max?(datos_oferta, edad_minima, edad_maxima)
  datos_oferta['edad_minima'] = edad_minima unless edad_minima.nil?
  datos_oferta['edad_maxima'] = edad_maxima unless edad_maxima.nil?
  datos_oferta
end
