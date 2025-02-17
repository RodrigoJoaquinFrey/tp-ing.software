require 'sinatra'
require 'sinatra/json'
require_relative './dominio/sistema_empleos'
require_relative './dominio/metodos_web_app'
require_relative './adaptadores/repositorio_usuarios_redis'
require_relative './adaptadores/repositorio_ofertas_redis'
require_relative './adaptadores/manejador_mail'
require_relative './adaptadores/proveedor_de_fecha'

configure do
  repositorio_usuarios = RepositorioUsuariosRedis.new
  repositorio_ofertas = RepositorioOfertasRedis.new
  manejador_mails = ManejadorMail.new
  proveedor_de_fecha = ProveedorDeFecha.new
  set :sistema_empleos,
      SistemaEmpleos.new(repositorio_usuarios, repositorio_ofertas, manejador_mails,
                         proveedor_de_fecha)
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

manejador_metodos = MetodosWebApp.new

get '/' do
  json({ mensaje: 'sistema empleos blanco' })
end

post '/reset' do
  sistema.reset
end

post '/usuarios' do
  nombre = params[:nombre_usuario]
  apellido = params[:apellido_usuario]
  mail = params[:mail_usuario]
  fecha_nacimiento = params[:fecha_nacimiento_usuario]
  parametros_esperados = {nombre_usuario: nombre, apellido_usuario: apellido,
                          mail_usuario: mail, fecha_nacimiento_usuario: fecha_nacimiento}
  parametro_faltante = manejador_metodos.validar_parametros_no_nil(parametros_esperados)
  if parametro_faltante
    halt(400,
         json({error: "Falta parametro obligatorio #{parametro_faltante}"}))
  end
  id_usuario = sistema.registrar_usuario(nombre, apellido, mail, fecha_nacimiento)
  json({ id_usuario: })
end

post '/ofertas' do
  titulo = params[:titulo_oferta]
  descripcion = params[:descripcion_oferta]
  mail = params[:mail_usuario]
  ubicacion_oferta = params[:ubicacion_oferta]
  remuneracion_ofrecida = params[:remuneracion_ofrecida].to_i if params[:remuneracion_ofrecida]
  edad_minima_postulacion = params[:edad_minima_postulacion].to_i if params[:edad_minima_postulacion]
  if params[:etiquetas]
    etiquetas = manejador_metodos.transformar_etiquetas_en_array(params[:etiquetas])
  end

  if remuneracion_ofrecida && remuneracion_ofrecida <= 0
    halt(400, json({ error: 'La remuneración debe ser un número entero positivo.' }))
  end
  if edad_minima_postulacion && (edad_minima_postulacion <= 0 || edad_minima_postulacion > 98)
    halt(400, json({ error: 'El campo de edad mínima debe ser un entero entre 0 y 99' }))
  end

  parametros_opcionales = {remuneracion_ofrecida:, ubicacion_oferta:, edad_minima_postulacion:, etiquetas:}

  parametros_esperados = {titulo_oferta: titulo, descripcion_oferta: descripcion,
                          mail_oferente: mail}
  parametro_faltante = manejador_metodos.validar_parametros_no_nil(parametros_esperados)
  if parametro_faltante
    halt(400,
         json({error: "Falta parametro obligatorio #{parametro_faltante}"}))
  end
  id_oferta = sistema.crear_oferta(titulo, descripcion, mail, parametros_opcionales)
  json({ id_oferta:})
end

get '/ofertas' do
  mail_usuario = params[:mail_usuario]&.gsub(' ', '+')

  ofertas = if mail_usuario
              sistema.buscar_ofertas_por_usuario(mail_usuario)
            else
              manejador_metodos.transformar_ofertas_en_dict(sistema.listar_ofertas)
            end
  json({ofertas:})
end

get '/ofertas/busqueda' do
  if params[:titulo] && params[:etiquetas]
    halt(400, json({ error: 'Solo puede haber un criterio de busqueda.' }))
  end

  if params[:titulo]
    titulo_buscado = params[:titulo]
    ofertas = sistema.buscar_ofertas_por_titulo(titulo_buscado)
  end
  if params[:etiquetas]
    etiquetas_buscadas = manejador_metodos.transformar_etiquetas_en_array(params[:etiquetas])
    ofertas = sistema.buscar_ofertas_por_etiquetas(etiquetas_buscadas)
  end

  json({ ofertas: })
rescue TituloABuscarInvalido => e
  halt(400, json({ error: e.message }))
end

post '/ofertas/:id_oferta/postulaciones' do
  id_oferta = params['id_oferta']
  mail_usuario_postulado = params[:mail_usuario_postulado]
  nombre_usuario_postulado = params[:nombre_usuario_postulado]
  apellido_usuario_postulado = params[:apellido_usuario_postulado]
  fecha_nacimiento_postulado = params[:fecha_nacimiento_postulado]

  parametros_esperados = { nombre_usuario_postulado:, apellido_usuario_postulado:,
                           mail_usuario_postulado:, fecha_nacimiento_postulado: }
  parametro_faltante = manejador_metodos.validar_parametros_no_nil(parametros_esperados)
  if parametro_faltante
    halt(400, json({ error: "Falta parametro obligatorio #{parametro_faltante}" }))
  end

  sistema.postulacion_ofertas(id_oferta, mail_usuario_postulado, nombre_usuario_postulado,
                              apellido_usuario_postulado, fecha_nacimiento_postulado)

  ofertas_sugeridas = sistema.ofertas_sugeridas(id_oferta)
  sugerencias = formatear_ofertas_sugeridas(ofertas_sugeridas)

  status 201
  json({ ofertas_sugeridas: sugerencias })
end

def formatear_ofertas_sugeridas(ofertas_sugeridas)
  ofertas_unicas = ofertas_sugeridas.uniq(&:id)
  ofertas_unicas.map do |oferta|
    {
      'id' => oferta.id,
      'titulo' => oferta.titulo,
      'descripcion' => oferta.descripcion,
      'mail' => oferta.mail,
      'remuneracion' => oferta.remuneracion_ofrecida,
      'ubicacion_oferta' => oferta.ubicacion_oferta,
      'etiquetas' => oferta.etiquetas,
      'edad_minima_postulacion' => oferta.edad_minima_postulacion
    }
  end
end

error StandardError do |e|
  halt 400, json({ error: e.message })
end
